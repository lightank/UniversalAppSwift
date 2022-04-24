//
//  LTLogInterface.m
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/4/23.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import "LTLogInterface.h"

@implementation LTLogInterface

+ (void)async:(BOOL)isAsync
        level:(LTLogLevelTyp)level
         file:(const char *)file
     function:(const char *)function
         line:(NSUInteger)line
          tag:(nullable NSString *)tag
       format:(NSString *)format, ... {
    va_list argList;
    va_start(argList, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
    va_end(argList);

    [self async:isAsync
        message:message
          level:level
           file:file
       function:function
           line:line
            tag:tag];
}

+ (void)async:(BOOL)isAsync
      message:(NSString *)message
        level:(LTLogLevelTyp)level
         file:(const char *)file
     function:(const char *)function
         line:(NSUInteger)line
          tag:(nullable NSString *)tag {
    if (level > LTLogLevelTypVerbose) {
        return;
    }
    [LTLogDispatcher.sharedInstance logMessageWithAsync:isAsync
                                 message:message
                                   level:level
                                    file:[NSString stringWithUTF8String:file]
                                function:[NSString stringWithUTF8String:function]
                                    line:line
                                     tag:tag];
}

@end
