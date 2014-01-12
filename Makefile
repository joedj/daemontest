TARGET := iphone:clang::5.0
ARCHS := armv7 arm64

ifdef CCC_ANALYZER_OUTPUT_FORMAT
  TARGET_CXX = $(CXX)
  TARGET_LD = $(TARGET_CXX)
endif

ADDITIONAL_CFLAGS += -g -fobjc-arc -fvisibility=hidden
ADDITIONAL_LDFLAGS += -g -fobjc-arc -x c /dev/null -x none

TWEAK_NAME = DaemonTestTweak
DaemonTestTweak_FILES = Tweak.x
DaemonTestTweak_PRIVATE_FRAMEWORKS = AppSupport

TOOL_NAME = daemontest
daemontest_FILES = daemon.m
daemontest_PRIVATE_FRAMEWORKS = AppSupport

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) \( -iname '*.plist' -or -iname '*.strings' \) -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -d -name '*.dSYM' -execdir rm -rf {} \;$(ECHO_END)

after-install::
	install.exec "(killall backboardd || killall SpringBoard) 2>/dev/null"

after-clean::
	rm -f *.deb
