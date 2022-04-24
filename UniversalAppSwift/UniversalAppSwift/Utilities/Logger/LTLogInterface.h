//
//  LTLogInterface.h
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/4/23.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniversalAppSwift-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface LTLogInterface : NSObject

+ (void)async:(BOOL)isAsync
        level:(LTLogLevelTyp)level
         file:(const char *)file
     function:(const char *)function
         line:(NSUInteger)line
          tag:(nullable NSString *)tag
       format:(NSString *)format, ...;

+ (void)async:(BOOL)isAsync
      message:(NSString *)message
        level:(LTLogLevelTyp)level
         file:(const char *)file
     function:(const char *)function
         line:(NSUInteger)line
          tag:(nullable NSString *)tag;

@end

NS_ASSUME_NONNULL_END
