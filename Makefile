.PHONY: build run open clean zip

SCHEME := KittenalLen
CONFIG := Debug
SDK := macosx
DERIVED := DerivedData
APP := $(DERIVED)/Build/Products/$(CONFIG)/$(SCHEME).app
ZIP := $(SCHEME).zip

build:
	xcodebuild -project KittenalLen.xcodeproj -scheme $(SCHEME) -configuration $(CONFIG) -sdk $(SDK) -derivedDataPath $(DERIVED) CODE_SIGN_IDENTITY=- build

run: build
	open $(APP)

open:
	open $(APP)

clean:
	rm -rf $(DERIVED)

zip: build
	ditto -c -k --keepParent $(APP) $(ZIP)
	@echo $(CURDIR)/$(ZIP)
