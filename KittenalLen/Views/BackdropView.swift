//
//  BackdropView.swift
//  Playground
//
//  Created by MeowCat on 2025/12/6.
//

import AppKit

// TODO: setting window transforms (or mission control) flattens layers...
// TODO: Mask image vs path (layer)?

/// `NSVisualEffectView`:
///
/// A view that adds translucency and vibrancy effects to the views in your interface.
/// When you want views to be more prominent in your interface, place them in a
/// backdrop view. The backdrop view is partially transparent, allowing some of
/// the underlying content to show through. Typically, you use a backdrop view
/// to blur background content, instead of obscuring it completely. It can also
/// make its contained content more vibrant to ensure that it remains prominent.
///
/// In addition, if the containing `NSWindow` is transformed in any way, including
/// through Mission Control/Exposé, the background blending will fail.
///
public class BackdropView: NSVisualEffectView {
    /// If multiple `BackdropView`s within the same layer tree (that is, window)
    /// share the same `BlendGroup`, they will be composited and blended
    /// together as a single continuous backdrop. However, setting different
    /// `effect`s may cause visual disparity; use with caution.
    public final class BlendGroup {
        
        /// The notification posted upon deinit of a `BlendGroup`.
        fileprivate static let removedNotification = Notification.Name("BackdropView.BlendGroup.deinit")
        
        /// The internal value used for `CABackdropLayer.groupName`.
        fileprivate let value = UUID().uuidString
        
        /// Create a new `BlendGroup`.
        public init() {}
        
        deinit {
            
            // Alert all `BackdropView`s that we're about to be removed.
            // The `BackdropView` will figure out if it needs to update itself.
            NotificationCenter.default.post(name: BlendGroup.removedNotification,
                                            object: nil, userInfo: ["value": self.value])
        }
        
        /// The `global` BlendGroup, if it is desired that all backdrops share
        /// the same blending group through the layer tree (window).
        public static let global = BlendGroup()
        
        /// The default internal value used for `CABackdropLayer.groupName`.
        /// This is to be used if no `BlendGroup` is set on the `BackdropView`.
        fileprivate static func `default`() -> String {
            return UUID().uuidString
        }
    }
    
    /// If `state` is set to `.followsWindowActiveState` or `NSWorkspace`'s
    /// `accessibilityDisplayShouldReduceTransparency` is true, the true visual
    /// state of the `BackdropView` may actually be `.active` or `.inactive`,
    /// and may change without notice. If such a state change occurs, this property
    /// governs whether or not that the visual change is animated.
    ///
    /// Note: this property is disregarded if properties are set within an active
    /// `NSAnimationContext` grouping.
    public var animatesImplicitStateChanges: Bool = false
    
    /// The visual effect to present within the `BackdropView`.
    public var backgroundColor: NSColor = .clear {
        didSet {
            self.transaction {
                self.backdrop.backgroundColor = self.backgroundColor.cgColor
            }
        }
    }
    
    /// If multiple `BackdropView`s within the same layer tree (that is, window)
    /// share the same `BlendGroup`, they will be composited and blended
    /// together as a single continuous backdrop. However, setting different
    /// `effect`s may cause visual disparity; use with caution.
    ///
    /// Note: you must retain any non-`global` `BlendGroup`s yourself.
    public weak var blendingGroup: BlendGroup? = nil {
        didSet {
            self.transaction {
                self.backdrop.groupName = self.blendingGroup?.value ?? BlendGroup.default()
            }
        }
    }
    
    /// The gaussian blur radius of the visual effect. Animatable.
    public var blurRadius: CGFloat {
        get { return self.backdrop.value(forKeyPath: "filters.gaussianBlur.inputRadius") as? CGFloat ?? 0 }
        set {
            self.transaction {
                self.backdrop.setValue(newValue, forKeyPath: "filters.gaussianBlur.inputRadius")
            }
        }
    }
    
    /// The background color saturation factor of the visual effect. Animatable.
    public var saturationFactor: CGFloat {
        get { return self.backdrop.value(forKeyPath: "filters.colorSaturate.inputAmount") as? CGFloat ?? 0 }
        set {
            self.transaction {
                self.backdrop.setValue(newValue, forKeyPath: "filters.colorSaturate.inputAmount")
            }
        }
    }
 
    private let backdrop = CABackdropLayer()
    //private var fallback: CAProxyLayer? = nil
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    private func setup() {
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        self.layer?.masksToBounds = false
        self.layer?.name = "view"
        
        // Set up our backdrop view:
        self.backdrop.name = "backdrop"
        self.backdrop.allowsGroupBlending = true
        self.backdrop.allowsGroupOpacity = true
        self.backdrop.allowsEdgeAntialiasing = false
        self.backdrop.disablesOccludedBackdropBlurs = true
        self.backdrop.ignoresOffscreenGroups = true
        self.backdrop.allowsInPlaceFiltering = false // blendgroups don't work otherwise
        self.backdrop.scale = 1.0 // 0.25 typically
        self.backdrop.bleedAmount = 0.0
        
        // Set up the backdrop filters:
        let blur = CAFilter(type: kCAFilterGaussianBlur)!
        let saturate = CAFilter(type: kCAFilterColorSaturate)!
        blur.setValue(true, forKey: "inputNormalizeEdges")
        self.backdrop.filters = [blur, saturate]
        
        // Set up the fallback layer used when the window is transformed:
        /*
        self.fallback = CAProxyLayer()
        self.fallback!.name = "fallback"
        self.fallback!.proxyProperties = [
            kCAProxyLayerLevel: 1,
            kCAProxyLayerActive: true,
            kCAProxyLayerBlendMode: "PlusD",
            kCAProxyLayerMaterial: "L"
        ]
        */
        
        // Set up the view:
        self.backdrop.masksToBounds = true
        self.backdrop.allowsGroupBlending = true
        self.backdrop.allowsEdgeAntialiasing = false
        
        // Essentially, tell the `NSVisualEffectView` to not do its job:
        super.state = .active
        self.setValue(true, forKey: "clear") // internal material
        self.layer?.insertSublayer(self.backdrop, at: 0)
        
        // Set our effect-related properties:
        self.blendingGroup = nil
        self.blurRadius = 5.0
        self.saturationFactor = 1.0
        
        // [Note] macOS 11+: no longer necessary to call `removeObserver` upon `deinit`.
        NotificationCenter.default.addObserver(self, selector: #selector(self.colorVariantsChanged(_:)),
                                               name: NSColor.systemColorsDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.blendGroupsChanged(_:)),
                                               name: BlendGroup.removedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.layerSurfaceChanged(_:)),
                                               name: BackdropView.layerSurfaceFlattenedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.layerSurfaceChanged(_:)),
                                               name: BackdropView.layerSurfaceFlushedNotification, object: nil)
    }
    
    /// Update sublayer `frame`.
    public override func layout() {
        super.layout()
        self.transaction(false) {
            self.backdrop.frame = self.layer?.bounds ?? .zero
            //self.fallback?.frame = self.layer?.bounds ?? .zero
        }
    }
    
    /// Update sublayer `contentsScale`.
    public override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        let scale = self.window?.backingScaleFactor ?? 1.0
        self.transaction(false) {
            self.layer?.contentsScale = scale
            self.backdrop.contentsScale = scale
            //self.fallback?.contentsScale = scale
        }
    }
    
    /// Toggle `CAProxyLayer` visibility if our layers were flattened.
    @objc private func layerSurfaceChanged(_ note: NSNotification!) {
//        guard let win = note.userInfo?["window"] as? NSWindow else { return }
        //let proxyVisible = note.userInfo?["proxy"] as? Bool ?? false
        
        /*
        // Update the `material` based on our `effectiveAppearance`.
        var props = self.fallback!.proxyProperties!
        props[kCAProxyLayerMaterial] = "L"//self.effectiveAppearance.name == .vibrantDark ? "D" : "L"
        self.fallback!.proxyProperties = props
        
        // Toggle visibility.
        CATransaction.begin()
        if proxyVisible {
            self.container.insertSublayer(self.fallback!, at: 1)
        } else {
            self.fallback!.removeFromSuperlayer()
        }
        CATransaction.commit()
        CATransaction.flush()
        */
    }
    
    /// Adjust our `BlendGroup` information if we need to.
    @objc private func blendGroupsChanged(_ note: NSNotification!) {
        guard let removed = note.userInfo?["value"] as? String else { return }
        guard backdrop.groupName == removed else { return }
        
        self.transaction(self.animatesImplicitStateChanges) {
            backdrop.groupName = BlendGroup.default() // was nil'd out
        }
    }
    
    /// Allow dynamic/system colors update themselves.
    @objc private func colorVariantsChanged(_ note: NSNotification!) {
        DispatchQueue.main.async {
            self.transaction(self.animatesImplicitStateChanges) {
                self.backdrop.backgroundColor = self.backgroundColor.cgColor
            }
        }
    }
    
    /// Creates a nested transaction whose actions are only enabled by default if
    /// called within an active `NSAnimationContext` grouping.
    ///
    /// Note: also sets the current NSAppearance for drawing purposes.
    private func transaction(_ actions: Bool? = nil, _ handler: () -> ()) {
        let actions = actions ?? CATransaction.value(forKey: "NSAnimationContextBeganGroup") as? Bool ?? false
        
        // NSAnimationContext handles per-thread activation of CATransaction for us.
        NSAnimationContext.beginGrouping()
        CATransaction.setDisableActions(!actions)
        NSAppearance.performAsCurrentDrawingAppearance(self.effectiveAppearance)(handler)
        NSAnimationContext.endGrouping()
    }
    
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        self.state = .active
        
        // Adjust the backdrop layer's WindowServer awareness.
        self.backdrop.windowServerAware = true
        
        // Set parent window configuration.
        if let newWindow = self.window {
            // If the window is not opaque, the `CABackdropLayer` cannot sample behind it.
            newWindow.isOpaque = false
            // If the window's `backgroundColor` is `.clear`, the theme frame/`borderView`
            // will unfortunately turn off corner masking, which then causes terrible
            // window resize lag. This is likely because without a mask, WindowServer
            // recomputes the "real shape" for any non-opaque windows.
            newWindow.backgroundColor = NSColor.white.withAlphaComponent(0.001)
        }
    }
    
    
    //
    // [Private SPI] HERE LIE DRAGONS!
    //
    
    /// Declared for NSVisualEffectView; affects non-contentView backdrops.
    @objc private func _shouldAutoFlattenLayerTree() -> Bool {
        return false
    }
    
    /// Emitted when we detect that our containing window was transformed.
    /// As of macOS 13, all layer surfaces are forcibly flattened when a window is transformed.
    ///
    /// `userInfo` keys:
    ///         - `window`: the window.
    ///         - `proxy`: boolean indicating CAProxyLayer usage.
    private static let layerSurfaceFlattenedNotification = Notification.Name("BackdropView.layerSurfaceFlattenedNotification")
    
    /// Emitted when we flush the layer surface after our containing window was un-transformed.
    ///
    /// `userInfo` keys:
    ///         - `window`: the window.
    ///         - `proxy`: boolean indicating CAProxyLayer usage.
    private static let layerSurfaceFlushedNotification = Notification.Name("BackdropView.layerSurfaceFlushedNotification")
}

@_silgen_name("CGSSetWindowTags")
func CGSSetWindowTags(_ cid: Int32, _ wid: Int32, _ tags: UnsafePointer<Int32>!, _ maxTagSize: Int) -> CGError
