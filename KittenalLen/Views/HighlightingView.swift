//
//  HighlightingView.swift
//  MacSwiftUIBlurTransparentWindowDemo
//
//  Created by MeowCat on 2025/12/13.
//
// Source - https://stackoverflow.com/a/75263911
// Posted by rob mayoff
// Retrieved 2025-12-07, License - CC BY-SA 4.0

import SwiftUI

struct HighlightingView<C: View, H: View>: View {
    @Namespace private var namespace
    
    var content: C
    
    var hightlight: H
    
    var position: CGPoint
    
    init(
        position: CGPoint,
        @ViewBuilder content: () -> C,
        @ViewBuilder highlight: () -> H
    ) {
        self.content = content()
        self.hightlight = highlight()
        self.position = position
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 20) {
                hightlight
                    .foregroundStyle(.clear)
                    .matchedGeometryEffect(
                        id: 2333, in: namespace,
                        properties: .frame, anchor: .center,
                        isSource: true)
            }.padding(20)
            .offset(x: position.x, y: position.y)
            ZStack(alignment: .topLeading) {
                content
                hightlight
                    .foregroundColor(.white)
                    .blur(radius: 30)
                    .matchedGeometryEffect(
                        id: 2333, in: namespace,
                        properties: .frame, anchor: .center,
                        isSource: false)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
        }
    }
}
