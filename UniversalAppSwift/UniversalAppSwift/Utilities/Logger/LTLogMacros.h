//
//  LTLogMacros.h
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/4/23.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import "LTLogInterface.h"

#ifndef LTLogMacros_h
#define LTLogMacros_h

#if DEBUG
    #define LTLOG_ASYNC_ENABLED NO
#else
    #define LTLOG_ASYNC_ENABLED YES
#endif

#define LTLOG_MACRO(isAsync, Level, Tag, Format, ...)          \
        [LTLogInterface async:isAsync                          \
                        level:Level                            \
                        file:__FILE__                          \
                        function:__PRETTY_FUNCTION__           \
                        line:__LINE__                          \
                        tag:Tag                                \
                        format:Format, ##__VA_ARGS__]

#define LTLOG_MAYBE(isAsync, Level, Tag, Format, ...) \
do { LTLOG_MACRO(isAsync, Level, Tag, Format, ##__VA_ARGS__);} while(0);

#define LTLogFatal(tag, format, ...)    LTLOG_MAYBE(NO, LTLogLevelTypFatal, tag, format ##__VA_ARGS__)
#define LTLogError(Tag, Format, ...)    LTLOG_MAYBE(LTLOG_ASYNC_ENABLED, LTLogLevelTypError, Tag, Format, ##__VA_ARGS__)
#define LTLogWarning(Tag, Format, ...)  LTLOG_MAYBE(LTLOG_ASYNC_ENABLED, LTLogLevelTypWarning, Tag, Format, ##__VA_ARGS__)
#define LTLogInfo(Tag, Format, ...)     LTLOG_MAYBE(LTLOG_ASYNC_ENABLED, LTLogLevelTypInfo, Tag, Format, ##__VA_ARGS__)
#define LTLogDebug(Tag, Format, ...)    LTLOG_MAYBE(LTLOG_ASYNC_ENABLED, LTLogLevelTypDebug, Tag, Format, ##__VA_ARGS__)
#define LTLogVerbose(Tag, Format, ...)  LTLOG_MAYBE(YES, LTLogLevelTypVerbose, Tag, Format, ##__VA_ARGS__)

/// General log
#define LTLog(Format, ...)              LTLogDebug(@"lt", Format, ##__VA_ARGS__)

#endif /* LTLogMacros_h */
