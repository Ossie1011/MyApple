ARCHS = arm64
TARGET = iphone:15.8:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MyBatteryNowPrefs
MyBatteryNowPrefs_FILES = MyBatteryNowPrefs.bundle/MBNRootListController.m
MyBatteryNowPrefs_INSTALL_PATH = /Library/PreferenceBundles
MyBatteryNowPrefs_FRAMEWORKS = UIKit
MyBatteryNowPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

TWEAK_NAME = MyBatteryNow
MyBatteryNow_FILES = Tweak.xm
MyBatteryNow_FRAMEWORKS = UIKit
MyBatteryNow_PRIVATE_FRAMEWORKS = SpringBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
