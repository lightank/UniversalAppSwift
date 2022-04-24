//
//  LoggerProtocol.swift
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/2/9.
//  Copyright © 2021 huanyu.li. All rights reserved.
//  iOS开发——自主设计日志系统: https://cloud.tencent.com/developer/article/1198767?from=article.detail.1198696

import Foundation

/// LoggerProtocol
@objc(LTLogDispatcherProtocol) public protocol LogDispatcherProtocol {
    /// 添加logger
    /// - Parameter logger: logger
    func addLogger(logger: LoggerProtocol)
    /// 移除logger
    /// - Parameter logger: logger
    func removeLogger(logger: LoggerProtocol)
    /// 移除全部logger
    /// - Parameter logger: logger
    func removeAllLogger(logger: LoggerProtocol)
    /// 分发消息
    /// - Parameter message: 日志消息
    func dispatchLogMessage(message: LogMessageProtocol, async: Bool)
}

/// LoggerProtocol
@objc(LTLoggerProtocol) public protocol LoggerProtocol {
    /// 标识唯一性
    var identifier: String {get}
    /// logger 所在的线程
    var queue: DispatchQueue? { get set }
    /// 是否应该记录这一条信息
    /// - Parameter message: log信息
    func shouldLogMessage(message: LogMessageProtocol) -> Bool
    /// 将信息格式化为字符串
    /// - Parameter message: log信息
    func formatLogMessage(message: LogMessageProtocol) -> String
    /// 记录这一条信息
    /// - Parameter message: log信息
    func logMessage(message: LogMessageProtocol)
}

@objc(LTLogLevelTyp) public enum LogMessageLevel: Int {
    /// 致命错误，阻塞交互，比如：闪退、界面异常等
    case fatal
    /// 普通错误，不影响交互
    case error
    /// 重要提示信息，建议用于提示一些处理不当就非常容易导致出现问题的信息
    case warning
    /// 普通信息，比如：用户操作的流程
    case info
    /// 开发过程中调试信息
    case debug
    /// 冗余信息，app 运行的全流程信息，比如：网络请求数据
    case verbose
}

/// LogMessageProtocol
@objc(LTLogMessageProtocol) public protocol LogMessageProtocol {
    /// 日志信息
    var message: String {get}
    /// 日志级别
    var level: LogMessageLevel {get}
    /// 日志级别对应名称
    var levelName: String {get}
    /// 记录这个日志的文件
    var file: String {get}
    /// 记录这个日志的方法
    var function: String {get}
    /// 记录这个日志的代码在文件中的行数
    var line: Int {get}
    /// 时间戳
    var timestamp: Date {get}
    /// 线程ID
    var threadID: String {get}
    /// 线程名称
    var threadName: String {get}
    /// 队列名
    var queueLabel: String {get}
    /// 重要的标识
    var tag: String? {get}
    /// 是否在主线程
    var isOnMainThread: Bool { get set }
}
