//
//  AppVender.m
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/4/15.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import "AppVender.h"
#import "UniversalAppSwift-Swift.h"
#import "LTDBLogger.h"
#import "LTXLogger.h"
#import "LTLogInterface.h"
#import "LTLogMacros.h"

@implementation AppVender

+ (void)configVender {
    [self configLog];
}

+ (void)configLog {
    [LTLogDispatcher.sharedInstance addLoggerWithLogger:[LTDBLogger new]];
    [LTLogDispatcher.sharedInstance addLoggerWithLogger:[LTXLogger new]];

    LTLog(@"this is a test log");
    LTLogFatal(@"lt", @"this is a fatal log");
    LTLogError(@"lt", @"this is a error log");
    LTLogWarning(@"lt", @"this is a warning log");
    LTLogInfo(@"lt", @"this is a info log");
    LTLogDebug(@"lt", @"this is a debug log");
    LTLogVerbose(@"lt", @"this is a verbose log");
}

@end
