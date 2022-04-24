//
//  LTXLogger.h
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/2/3.
//  Copyright © 2021 huanyu.li. All rights reserved.
//  Xlog接入文档：https://github.com/Tencent/mars/wiki/Mars-iOS%EF%BC%8FOS-X-%E6%8E%A5%E5%85%A5%E6%8C%87%E5%8D%97
//  Swift 不支持 C++ 混编，Swift 调用 C++ 方法需要走 Objective-C 中转才行，导致必须有个 Objective-C 的中间类 😢
//  详见：https://glumes.com/post/ios/swift-call-c-function/

#import <Foundation/Foundation.h>
#import "UniversalAppSwift-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface LTXLogger : NSObject <LTLoggerProtocol>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, nullable) dispatch_queue_t queue;

@end

NS_ASSUME_NONNULL_END
