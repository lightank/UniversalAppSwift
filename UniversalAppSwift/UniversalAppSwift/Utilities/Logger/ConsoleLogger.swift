//
//  ConsoleLogger.swift
//  UniversalAppSwift
//
//  Created by huanyu.li on 2021/4/13.
//  Copyright © 2021 huanyu.li. All rights reserved.
//

import Foundation
import SwiftDate

class ConsoleLogger {
    private var innerQueue: DispatchQueue?
    static let sharedInstance = ConsoleLogger()
}

extension ConsoleLogger: LoggerProtocol {
    var identifier: String {
        "console"
    }

    var queue: DispatchQueue? {
        get {
            return innerQueue
        }
        set (newValue) {
            innerQueue = newValue
        }
    }

    func shouldLogMessage(message: LogMessageProtocol) -> Bool {
        return true
    }

    func formatLogMessage(message: LogMessageProtocol) -> String {
        let time = "\(message.timestamp.hour):\(message.timestamp.minute):\(message.timestamp.second)"
        let threadType = message.isOnMainThread ? "M-Thread" : "B-Thread"
        let conent = "\(time) [\(vividUnicode(level: message.level)) \(message.levelName)] [\(threadType)] "
            + String(describing: message.tag)
            + ":" + message.message

        return conent
    }

    func logMessage(message: LogMessageProtocol) {
        if (!shouldLogMessage(message: message)) {
            return
        }

        print("\(formatLogMessage(message: message)) \n")
    }

    func vividUnicode(level: LogMessageLevel) -> String {
        switch level {
        case .fatal:
            return "☠️"
        case .error:
            return "❌"
        case .warning:
            return "❗️"
        case .info:
            return "❕"
        case .debug:
            return "❔"
        case .verbose:
            return "✅"
        }
    }
}
