//
//  LTDBLogger.m
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/2/10.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import "LTDBLogger.h"

@interface LTDBLogger ()

@property (nonatomic, copy) NSString *logDirectory;
@property (nonatomic, strong) NSMutableArray<DDLogMessage *> *pendingLogEntries;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;

@property (nonatomic, strong) NSArray *logUUIDsToUpload;
@property (nonatomic, assign) NSUInteger unuploadedLogsNum;

@end

@implementation LTDBLogger

- (instancetype)initWithLogDirectory:(NSString *)aLogDirectory {
    if ((self = [super init])) {
        _identifier = @"DDLog";
        _logDirectory = [aLogDirectory copy];
        _pendingLogEntries = [[NSMutableArray alloc] initWithCapacity:_saveThreshold];

        [self validateLogDirectory];
        [self openDatabase];

        self.unuploadedLogsNum = [self queryCountOfUnuploadedLogs];
    }

    return self;
}

- (void)validateLogDirectory {
    // Validate log directory exists or create the directory.
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.logDirectory isDirectory:&isDirectory]) {
        if (!isDirectory)
        {
            NSLog(@"%@: %@ - logDirectory(%@) is a file!", [self class], THIS_METHOD, self.logDirectory);
            self.logDirectory = nil;
        }
    } else {
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:self.logDirectory
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:&error];
        if (!result) {
            NSLog(@"%@: %@ - Unable to create logDirectory(%@) due to error: %@",
                  [self class], THIS_METHOD, self.logDirectory, error);

            self.logDirectory = nil;
        }
    }
}

- (void)openDatabase {
    if (self.logDirectory == nil) {
        return;
    }

    NSString *path = [self.logDirectory stringByAppendingPathComponent:@"log.sqlite"];

    self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:path];

    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            NSString *cmd1 = @"CREATE TABLE IF NOT EXISTS logs (uuid text,"
                                                               "context integer, "
                                                               "level integer, "
                                                               "message text, "
                                                               "timestamp double, "
                                                               "uploaded boolean)";
            [db executeUpdate:cmd1];
            if (![db hadError]) {
                NSLog(@"创建表成功");
            }
            else{
                NSLog(@"创建表失败");
                NSLog(@"%@: Error creating table: code(%d): %@", [strongSelf class], [db lastErrorCode], [db lastErrorMessage]);
                strongSelf.databaseQueue = nil;
            }
        }
    }];

    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *cmd2 = @"CREATE INDEX IF NOT EXISTS timestamp ON logs (timestamp)";
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [db executeUpdate:cmd2];
            [db setShouldCacheStatements:YES];
            if ([db hadError])
            {
                NSLog(@"%@: Error creating index: code(%d): %@", [strongSelf class], [db lastErrorCode], [db lastErrorMessage]);

                strongSelf.databaseQueue = nil;
            }
        }

    }];
}

#pragma mark - LTLoggerProtocol

- (NSString * _Nonnull)formatLogMessageWithMessage:(id<LTLogMessageProtocol> _Nonnull)message {
    NSString *log = [NSString stringWithFormat:@"%@-%@-%@: %@", message.tag, message.threadName, message.queueLabel, message.message];
    return log;
}

- (void)logMessageWithMessage:(id<LTLogMessageProtocol> _Nonnull)message {
    //TODO: (huanyu) transfer LTLogMessage to DDLogMessage, and save it
}

- (BOOL)shouldLogMessageWithMessage:(id<LTLogMessageProtocol> _Nonnull)message {
    return YES;
}

#pragma mark - AbstractDatabaseLogger

- (BOOL)db_log:(DDLogMessage *)logMessage {
    [_pendingLogEntries addObject:logMessage];

    return YES;
}

- (void)db_save {
    if (_pendingLogEntries.count == 0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [db beginTransaction];

            NSString *cmd = @"INSERT INTO logs (uuid, context, level, message, timestamp, uploaded) VALUES (?, ?, ?, ?, ?, 0)";

            NSUInteger count = strongSelf.pendingLogEntries.count;
            for (DDLogMessage *logMessage in strongSelf.pendingLogEntries) {
                [db executeUpdate:cmd,
                 [NSUUID UUID].UUIDString,
                 logMessage->_context,
                 logMessage->_flag,
                 logMessage->_message,
                 logMessage->_timestamp];
            }

            [strongSelf.pendingLogEntries removeAllObjects];
            [db commit];

            if ([db hadError]) {
                NSLog(@"新增数据失败");
                NSLog(@"%@: Error inserting log entries: code(%d): %@", [strongSelf class], [db lastErrorCode], [db lastErrorMessage]);
            } else {
                NSLog(@"新增数据成功");
                if (![db hadError]) {
                    strongSelf.unuploadedLogsNum += count;
                }

                //TODO: (huanyu) 这里需要设置一个上传日志阈值
                if (strongSelf.unuploadedLogsNum >= 10000) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if (strongSelf.unuploadLogsNumReachedMaxBlock) {
                            strongSelf.unuploadLogsNumReachedMaxBlock();
                        }
                    });
                }
            }
        }

    }];
}

- (void)db_delete {
    if (_maxAge <= 0.0) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:(-1.0 * strongSelf->_maxAge)];
            [db executeUpdate:@"DELETE FROM logs WHERE timestamp < ? and uploaded = 1", maxDate];

            if ([db hadError])
            {
                NSLog(@"%@: Error deleting log entries: code(%d): %@",
                      [strongSelf class], [db lastErrorCode], [db lastErrorMessage]);
            }
        }
    }];
}

- (void)db_saveAndDelete {
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [db beginTransaction];

            [strongSelf db_delete];
            [strongSelf db_save];

            [db commit];
            if ([db hadError]) {
                NSLog(@"%@: Error: code(%d): %@", [strongSelf class], [db lastErrorCode], [db lastErrorMessage]);
            }
        }
    }];

}

- (NSUInteger)queryCountOfUnuploadedLogs {
    __block NSUInteger totalCount = 0;
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            FMResultSet *resultSet = [db executeQuery:@"select count(*) from logs where uploaded = 0"];
            if ([resultSet next]) {
                totalCount = [resultSet intForColumnIndex:0];
            }
            [resultSet close];
        }
    }];

    return totalCount;
}

- (NSArray *)fectchLogsToUpload {
    NSMutableArray *messages = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            //TODO: (huanyu) 需要设置每次上传的最大数
            FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat: @"select * from logs where uploaded = 0 order by timestamp asc limit %d", 200]];
            NSMutableArray *uuids = [NSMutableArray array];
            while ([resultSet next]) {
                NSString *message = [resultSet objectForColumn:@"message"];
                NSString *uuid = [resultSet objectForColumn:@"uuid"];
                [messages addObject:message];
                [uuids addObject:uuid];
            }
            [resultSet close];
            strongSelf.logUUIDsToUpload = uuids;
        }
    }];

    return messages;
}

- (void)markLogsUploaded {
    __weak typeof(self) weakSelf = self;
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [db beginTransaction];

            NSUInteger count = strongSelf.logUUIDsToUpload.count;
            for (NSString *uuid in strongSelf.logUUIDsToUpload) {
                [db executeUpdate:@"update logs set uploaded = 1 where uuid = ?", uuid];
            }

            [db commit];
            strongSelf.logUUIDsToUpload = nil;

            if (![db hadError]) {
                strongSelf.unuploadedLogsNum -= count;
            }
        }
    }];
}

@end
