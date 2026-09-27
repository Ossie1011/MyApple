#import <UIKit/UIKit.h>

static BOOL   MBNEnabled     = YES;
static int    MBNPercentage  = 100;
static NSString *MBNColorName = @"System";

static void MBNLoadPrefs() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.yourname.mybatterynow"),
		kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	NSDictionary *prefs = nil;
	if (keyList) {
		prefs = (NSDictionary *)CFBridgingRelease(
			CFPreferencesCopyMultiple(keyList, CFSTR("com.yourname.mybatterynow"),
				kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	}

	MBNEnabled    = prefs[@"MBNEnabled"] ? [prefs[@"MBNEnabled"] boolValue] : YES;
	MBNPercentage = prefs[@"MBNPercentage"] ? [prefs[@"MBNPercentage"] intValue] : 100;
	MBNColorName  = prefs[@"MBNTextColor"] ?: @"System";
}

static UIColor *MBNColor() {
	if ([MBNColorName isEqualToString:@"White"])  return [UIColor whiteColor];
	if ([MBNColorName isEqualToString:@"Black"])  return [UIColor blackColor];
	if ([MBNColorName isEqualToString:@"Green"])  return [UIColor systemGreenColor];
	if ([MBNColorName isEqualToString:@"Red"])    return [UIColor systemRedColor];
	if ([MBNColorName isEqualToString:@"Orange"]) return [UIColor systemOrangeColor];
	if ([MBNColorName isEqualToString:@"Blue"])   return [UIColor systemBlueColor];
	return nil; // nil = leave system default colour alone
}

/*
 * _UIBatteryView is the private SpringBoard class that draws the status
 * bar / Control Center battery icon on iOS 15. Its "chargePercent" property
 * (0.0-1.0) drives both the fill amount AND the percentage label text, so
 * overriding the getter changes both consistently. This is confirmed via
 * the open-source "Ampere" tweak (MIT licensed), which hooks this exact
 * class on iOS 14/15/16.
 */
%hook _UIBatteryView

- (CGFloat)chargePercent {
	if (MBNEnabled) {
		return (CGFloat)MBNPercentage / 100.0;
	}
	return %orig;
}

- (id)_batteryTextColor {
	UIColor *override = MBNColor();
	if (MBNEnabled && override) {
		return override;
	}
	return %orig;
}

%end

%ctor {
	MBNLoadPrefs();
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		(CFNotificationCallback)MBNLoadPrefs,
		CFSTR("com.yourname.mybatterynow/reload"),
		NULL,
		CFNotificationSuspensionBehaviorCoalesce);
}
