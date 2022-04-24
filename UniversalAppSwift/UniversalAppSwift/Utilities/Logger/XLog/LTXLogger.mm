//
//  LTXLogger.m
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/2/3.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTXLogger.h"

#import <sys/xattr.h>

#import <mars/xlog/xloggerbase.h>
#import <mars/xlog/appender.h>
#import <mars/xlog/xlogger_interface.h>

@implementation LTXLogger

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initXLogger];
    });
}

+ (void)initXLogger {
    int maxStorageDate = 30;
    
    NSString* logPath = [self logPath];
    
    xlogger_SetLevel(kLevelAll);
    appender_set_console_log(false);
    appender_set_max_alive_duration(maxStorageDate);
    
    
    XLogConfig config;
    config.logdir_ = [logPath UTF8String];
    config.nameprefix_ = "LT";
    /*
     Xlog 加密使用指引：https://www.bookstack.cn/read/mars/86c33132ef2ede4c.md 公钥为空则只压缩不加密
     生成加解密秘钥的脚本路径：mars/log/crypt/gen_key.py，执行脚本：
     
     $ python gen_key.py
     WARNING: Executing a script that is loading libcrypto in an unsafe way. This will fail in a future version of macOS. Set the LIBRESSL_REDIRECT_STUB_ABORT=1 in the environment to force this into an error.
     save private key
     c20dce70b818cf774f264abbb0684245233d411ba83f54ad66012805640568ee

     appender_open's parameter:
     9e5a7d4366e5e32830f8f343fddd244d15ddbf4e4a132cf0c0627bd9b0342a1edf2510f582e2a373ccbd8257678bc73fa919e6d6caff9aa532552e91a611fa3f
     
     注意：
     PUB_KEY 就是：appender_open's parameter
     */
    config.pub_key_ = "";
    // 最大存储日期
    config.cache_days_ = 30;
    
    appender_open(config);
}

+ (NSString *)logPath {
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logPath = [[cache stringByAppendingPathComponent:@"log"] stringByAppendingPathComponent:@"xlog"];
    
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:logPath isDirectory:&isDirectory];
    if (exists && isDirectory) {
        return logPath;
    }
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:logPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        NSLog(@"error to failed create directory, error = %@", error);
    } else {
        // 阻止 iCloud 同步
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        setxattr([logPath UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);
    }
    return logPath;
}

- (instancetype)init {
    if (self = [super init]) {
        _identifier = @"XLog";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)appWillTerminate:(NSNotification *)notification {
    appender_close();
}

- (BOOL)shouldLogMessageWithMessage:(id<LTLogMessageProtocol>)message {
    return YES;
}

- (NSString *)formattedMessageWithMessage:(id<LTLogMessageProtocol>)message {
    NSString *log = [NSString stringWithFormat:@"%@-%@-%@: %@", message.tag, message.threadName, message.queueLabel, message.message];
    return log;
}

- (void)logMessageWithMessage:(id<LTLogMessageProtocol>)message {
    XLoggerInfo info;
    info.level = xlogLevelForMessage(message);
    info.filename = message.file.UTF8String;
    info.func_name = message.function.UTF8String;
    info.line = (int)message.line;
    info.tag = message.tag.UTF8String;
    
    double timestamp = [message.timestamp timeIntervalSince1970];
    info.timeval.tv_sec = static_cast<__darwin_time_t>(timestamp);
    info.timeval.tv_usec = static_cast<__darwin_suseconds_t>((timestamp - info.timeval.tv_sec) * 1000);
    
    info.tid = message.threadID.longLongValue;
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = xlogger_pid();
    
    // xlog 有16k限制，超过16K分片
    NSString *log = [self formattedMessageWithMessage:message];
    NSInteger len = log.length;
    NSInteger fixed = 1024 * 8;
    NSInteger segments = ceilf((float)len / (float)fixed);
    for (int i = 0; i < segments; i++) {
        @autoreleasepool {
            NSInteger rangPos = i * fixed;
            NSInteger rangLen = len - rangPos > fixed ? fixed : len - rangPos;
            xlogger_Write(&info, [log substringWithRange:NSMakeRange(rangPos, rangLen)].UTF8String);
        }
    }
}

- (NSString *)formatLogMessageWithMessage:(id<LTLogMessageProtocol>)message {
    NSString *log = [NSString stringWithFormat:@"%@-%@-%@: %@", message.tag, message.threadName, message.queueLabel, message.message];
    return log;
}


static TLogLevel xlogLevelForMessage(id<LTLogMessageProtocol> message) {
    switch (message.level) {
        case LTLogLevelTypFatal:
            return kLevelFatal;
        case LTLogLevelTypError:
            return kLevelError;
        case LTLogLevelTypWarning:
            return kLevelWarn;
        case LTLogLevelTypInfo:
            return kLevelInfo;
        case LTLogLevelTypDebug:
            return kLevelDebug;
        case LTLogLevelTypVerbose:
            return kLevelVerbose;
    }
}

@end
