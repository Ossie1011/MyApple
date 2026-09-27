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
 * ---- THE PART YOU MUST VERIFY ON-DEVICE ----
 * The class/method below is the general shape every "fake battery" tweak
 * uses, but Apple's internal SpringBoard class names shift between iOS
 * versions/point releases. On iOS 15.8.x the battery number in the status
 * bar and Control Center is owned by a battery data/controller class
 * (historically named things like SBBatteryDataStatusItem /
 * SBBatteryLevelController / SBFBatteryController depending on version).
 *
 * To find the right one on YOUR 15.8.8 device:
 *   1. class-dump or dump SpringBoard's binary
 *   2. grep for "battery" (case-insensitive) in class names
 *   3. Look for a method returning a float/double (0.0-1.0) "level" or an
 *      NSInteger "percentage", and a separate label/string formatter.
 *   4. Hook the LEVEL getter (below) rather than the label text, so every
 *      consumer (status bar, lock screen, Control Center, Settings) updates
 *      together - hooking a single label only changes one place.
 *
 * Once you've confirmed the class name, replace ExampleBatteryController
 * and exampleBatteryLevel below with the real ones.
 */

%hook ExampleBatteryController

- (float)exampleBatteryLevel {
	if (MBNEnabled) {
		return (float)MBNPercentage / 100.0f;
	}
	return %orig;
}

%end

/* Optional: if the status bar renders its own percentage text label,
 * you can additionally recolour it here once you've found its class. */
%hook ExampleBatteryTextLabel

- (void)setTextColor:(UIColor *)color {
	UIColor *override = MBNColor();
	%orig(override ? override : color);
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
