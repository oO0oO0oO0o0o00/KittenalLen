.PHONY: build run open clean

SCHEME := KittenalLen
CONFIG := Debug
SDK := macosx
DERIVED := DerivedData
APP := $(DERIVED)/Build/Products/$(CONFIG)/$(SCHEME).app

build:
	xcodebuild -project KittenalLen.xcodeproj -scheme $(SCHEME) -configuration $(CONFIG) -sdk $(SDK) -derivedDataPath $(DERIVED) CODE_SIGN_IDENTITY=- build

run: build
	open $(APP)

open:
	open $(APP)

clean:
	rm -rf $(DERIVED)
