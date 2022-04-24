//
//  LTDBLogger.h
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/2/10.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/DDAbstractDatabaseLogger.h>
#import <FMDB/FMDB.h>
#import "UniversalAppSwift-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

@interface LTDBLogger : DDAbstractDatabaseLogger <LTLoggerProtocol>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, nullable) dispatch_queue_t queue;
@property (nonatomic, copy) void(^unuploadLogsNumReachedMaxBlock)(void);

/**
 * Initializes an instance set to save it's sqlite file to the given directory.
 * If the directory doesn't already exist, it is automatically created.
 **/
- (instancetype)initWithLogDirectory:(NSString *)logDirectory;

- (NSArray *)fectchLogsToUpload;
- (void)markLogsUploaded;

@end

NS_ASSUME_NONNULL_END
