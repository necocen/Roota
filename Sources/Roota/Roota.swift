//
//  Roota.swift
//  
//
//  Created by necocen on 2020/12/02.
//

import Foundation

public enum Roota {
    static var logHandler: ((_ message: @autoclosure @escaping () -> String, _ functionName: StaticString, _ fileName: StaticString, _ lineNumber: Int, _ dso: UnsafeRawPointer) -> Void) = { message, _, _, _, _ in
        NSLog("[Roota] %@", message())
    }

    internal static func log(_ message: @autoclosure @escaping () -> String, _ functionName: StaticString = #function, _ fileName: StaticString = #file, _ lineNumber: Int = #line, _ dso: UnsafeRawPointer = #dsohandle) {
        logHandler(message(), functionName, fileName, lineNumber, dso)
    }
}
