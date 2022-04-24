//
//  LogDispatcher.swift
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/3/18.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

import Foundation
import YYKit

@objc(LTLogDispatcher) public class LogDispatcher : NSObject {
    @objc public static let sharedInstance = LogDispatcher()
    private let semaphore = DispatchSemaphore(value: 1)
    private var loggers = [LoggerProtocol]()
    private let group = DispatchGroup()
    private var queuePool: YYDispatchQueuePool?
    private var queue: DispatchQueue {
        if self.queuePool == nil {
            var queueCount = 0
            self.loggers.forEach { (logger) in
                if logger.queue == nil {
                    queueCount += 1
                }
            }
            self.queuePool = YYDispatchQueuePool(name: "com.lightank.log-queue-pool",
                                                 queueCount: UInt(max(1, queueCount)),
                                                 qos: .utility)
        }
        return self.queuePool!.queue()
    }

    public func configLogger() {
        self.addLogger(logger: ConsoleLogger())
    }
}

extension LogDispatcher: LogDispatcherProtocol {
    public func addLogger(logger: LoggerProtocol) {
        _ = semaphore.wait(timeout: .distantFuture)
        if (!loggers.contains(where: { (innerLogger) -> Bool in
            innerLogger.identifier == logger.identifier
        })) {
            loggers.append(logger)
            queuePool = nil
        }
        semaphore.signal()
    }

    public func removeLogger(logger: LoggerProtocol) {
        _ = semaphore.wait(timeout: .distantFuture)
        if (loggers.contains(where: { (innerLogger) -> Bool in
            innerLogger.identifier == logger.identifier
        })) {
            loggers.removeAll(where: { (innerLogger) -> Bool in
                innerLogger.identifier == logger.identifier
            })
            queuePool = nil
        }
        semaphore.signal()
    }

    public func removeAllLogger(logger: LoggerProtocol) {
        _ = semaphore.wait(timeout: .distantFuture)
        loggers.removeAll(where: { (_) -> Bool in
            true
        })
        queuePool = nil
        semaphore.signal()
    }

    public func dispatchLogMessage(message: LogMessageProtocol, async: Bool) {
        _ = semaphore.wait(timeout: .distantFuture)
        if async {
            loggers.forEach { (logger) in
                if logger.queue == nil {
                    logger.queue = self.queue
                }
                logger.queue?.async(execute: {
                    logger.logMessage(message: message)
                })
            }
        } else {
            loggers.forEach { (logger) in
                if logger.queue == nil {
                    logger.queue = self.queue
                }
                logger.queue?.async(group: group, execute: {
                    logger.logMessage(message: message)
                })
                // wait until all logger write
                _ = group.wait(timeout: .distantFuture)
            }
        }
        semaphore.signal()
    }

    @objc public func logMessage(async: Bool,
                                 message: String,
                                 level: LogMessageLevel,
                                 file: String = #file,
                                 function: String = #function,
                                 line: Int = #line,
                                 tag: String?) {
        /// Swift Language Reference defines:
        /// https://docs.swift.org/swift-book/ReferenceManual/Expressions.html#//apple_ref/doc/uid/TP40014097-CH32-ID390
        /// Literal        Type     Value
        /// #file          String   The name of the file in which it appears.
        /// #line          Int      The line number on which it appears.
        /// #column        Int      The column number in which it begins.
        /// #function      String   The name of the declaration in which it appears.
        let logMessage = LogMessage(message: message,
                                    level: level,
                                    file: file,
                                    function: function,
                                    line: line,
                                    timestamp: Date(),
                                    tag: tag)
        dispatchLogMessage(message: logMessage, async: async)
    }
}

/// 日志是否异步
/// - Returns: async
private func log_async_enabled() -> Bool {
    #if DEBUG
    return false
    #else
    return true
    #endif
}

/// log Fatal 级别日志
/// - Parameters:
///   - tag: 日志tag
///   - message: 日志内容
///   - file: 代码所在文件
///   - function: 代码所在方法名
///   - line: 代码所在行数
public func logFatal(tag: String?,
                     message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
    LogDispatcher.sharedInstance.logMessage(async: false, message: message, level: .fatal, tag: tag)
}

/// log Error 级别日志
/// - Parameters:
///   - tag: 日志tag
///   - message: 日志内容
///   - file: 代码所在文件
///   - function: 代码所在方法名
///   - line: 代码所在行数
public func logError(tag: String?,
                     message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
    LogDispatcher.sharedInstance.logMessage(async: log_async_enabled(), message: message, level: .fatal, tag: tag)
}

/// log Warning 级别日志
/// - Parameters:
///   - tag: 日志tag
///   - message: 日志内容
///   - file: 代码所在文件
///   - function: 代码所在方法名
///   - line: 代码所在行数
public func logWarning(tag: String?,
                       message: String,
                       file: String = #file,
                       function: String = #function,
                       line: Int = #line) {
    LogDispatcher.sharedInstance.logMessage(async: log_async_enabled(), message: message, level: .fatal, tag: tag)
}

/// log Info 级别日志
/// - Parameters:
///   - tag: 日志tag
///   - message: 日志内容
///   - file: 代码所在文件
///   - function: 代码所在方法名
///   - line: 代码所在行数
public func logInfo(tag: String?,
                    message: String,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
    LogDispatcher.sharedInstance.logMessage(async: log_async_enabled(), message: message, level: .fatal, tag: tag)
}

/// log Debug 级别日志
/// - Parameters:
///   - tag: 日志tag
///   - message: 日志内容
///   - file: 代码所在文件
///   - function: 代码所在方法名
///   - line: 代码所在行数
public func logDebug(tag: String?,
                     message: String,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
    LogDispatcher.sharedInstance.logMessage(async: log_async_enabled(), message: message, level: .fatal, tag: tag)
}

/// log Verbos 级别日志
/// - Parameters:
///   - tag: 日志tag
///   - message: 日志内容
///   - file: 代码所在文件
///   - function: 代码所在方法名
///   - line: 代码所在行数
public func logVerbos(tag: String?,
                      message: String,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    LogDispatcher.sharedInstance.logMessage(async: true, message: message, level: .fatal, tag: tag)
}
