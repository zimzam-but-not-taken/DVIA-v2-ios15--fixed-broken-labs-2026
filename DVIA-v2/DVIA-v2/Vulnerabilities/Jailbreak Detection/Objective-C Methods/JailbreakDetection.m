//
//  JailbreakDetection.m
//  Created by Prateek Gianchandani on 25/11/17.
//  DVIA - Damn Vulnerable iOS App (damnvulnerableiosapp.com)
//  Copyright © 2018 HighAltitudeHacks. All rights reserved.
//  You are free to use this app for commercial or non-commercial purposes
//  You are also allowed to use this in trainings
//  However, if you benefit from this project and want to make a contribution, please consider making a donation to The Juniper Fund (www.thejuniperfund.org/)
//  The Juniper fund is focusing on Nepali workers involved with climbing and expedition support in the high mountains of Nepal. When a high altitude worker has an accident (death or debilitating injury), the impact to the family is huge. The juniper fund provides funds to the affected families and help them set up a sustainable business.
//  For more information,  visit www.thejuniperfund.org
//  Or watch this video https://www.youtube.com/watch?v=HsV6jaA5J2I
//  And this https://www.youtube.com/watch?v=6dHXcoF590E


#import <Foundation/Foundation.h>
#import "JailbreakDetection.h"

@implementation JailbreakDetection

+(BOOL)isJailbroken{

#if !(TARGET_IPHONE_SIMULATOR)

    // Rootful and rootless (/var/jb) artefacts
    NSArray<NSString *> *paths = @[
        @"/Applications/Cydia.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries",
        @"/usr/lib/libhooker.dylib",
        @"/usr/lib/libsubstitute.dylib",
        @"/usr/lib/TweakInject",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/usr/bin/ssh",
        @"/etc/apt",
        @"/private/var/lib/apt",
        @"/.installed_unc0ver",
        @"/.bootstrapped_electra",
        @"/var/jb",
        @"/var/jb/Applications/Sileo.app",
        @"/var/jb/Applications/Zebra.app",
        @"/var/jb/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/var/jb/Library/MobileSubstrate/DynamicLibraries",
        @"/var/jb/usr/lib/libellekit.dylib",
        @"/var/jb/usr/lib/libhooker.dylib",
        @"/var/jb/usr/bin/ssh",
        @"/var/jb/etc/apt",
        @"/var/jb/.installed_dopamine",
        @"/var/jb/basebin/jailbreakd",
        @"/.installed_palera1n",
        @"/var/mobile/Library/palera1n",
        @"/cores/binpack"
    ];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }

    // Sandbox escape: can we write outside the container?
    NSError *error = nil;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if(error==nil){
        //Device is jailbroken
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
        return YES;
    }

    // Package managers (schemes must be whitelisted in LSApplicationQueriesSchemes)
    NSArray<NSString *> *schemes = @[
        @"cydia://package/com.example.package",
        @"sileo://package/com.example.package",
        @"zbra://",
        @"filza://"
    ];
    for (NSString *scheme in schemes) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]){
            //Device is jailbroken
            return YES;
        }
    }

#endif

    //All checks have failed. Most probably, the device is not jailbroken
    return NO;
}


@end
