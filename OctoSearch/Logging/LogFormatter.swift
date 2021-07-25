//
//  LogFormatter.swift
//  OctoSearch
//

import Foundation
import CocoaLumberjack

public class LogFormatter: NSObject, DDLogFormatter {
    let dateFormatter: DateFormatter
    
    override public init() {
        dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        super.init()
    }
    
    public func format(message logMessage: DDLogMessage) -> String? {
        let dateAndTime = dateFormatter.string(from: logMessage.timestamp)
        
        var logLevelStr = "I"
        switch logMessage.level {
        case .error:
            logLevelStr = "E"
        case .warning:
            logLevelStr = "W"
        case .info:
            logLevelStr = "I"
        case .debug:
            logLevelStr = "D"
        default:
            logLevelStr = "I"
        }
        
        return "\(dateAndTime) \(logLevelStr) [\(logMessage.threadID)] [\(logMessage.fileName).\(logMessage.function ?? ""):\(logMessage.line)]: \(logMessage.message)"
    }
}
