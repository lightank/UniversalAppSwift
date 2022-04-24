//
//  LogMessage.swift
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/4/14.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

import Foundation

class LogMessage: LogMessageProtocol {
    var message: String
    var level: LogMessageLevel
    var levelName: String {
        switch level {
        case .fatal:
            return "Fatal"
        case .error:
            return "Error"
        case .warning:
            return "Warn"
        case .info:
            return "Info"
        case .debug:
            return "Debug"
        case .verbose:
            return "Verbose"
        }
    }

    var file: String
    var function: String
    var line: Int
    var timestamp: Date
    var threadID: String
    var threadName: String
    var queueLabel: String
    var tag: String?
    var isOnMainThread: Bool

    init(message: String,
         level: LogMessageLevel,
         file: String,
         function: String,
         line: Int,
         timestamp: Date?,
         tag: String?) {
        self.message = message
        self.level = level
        self.file = file
        self.function = function
        self.line = line
        self.timestamp = timestamp ?? Date()
        self.tag = tag

        self.threadName = Thread.current.name ?? ""
        var tid:__uint64_t = 0
        pthread_threadid_np(nil, &tid)
        self.threadID = String(tid)
        self.isOnMainThread = Thread.current.isMainThread
        self.queueLabel = OperationQueue.current?.underlyingQueue?.label ?? ""
    }
}
