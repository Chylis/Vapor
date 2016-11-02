//
//  LogFilter.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-30.
//
//

import Foundation
import HTTP

final class LogFilter: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let input = "Incoming: '\(request)'"
        let output: String
        
        defer {
            //NOTE: Use Date().timeIntervalSinceReferenceDate (I found out the hard way that 'let tag = "\(Date())"' causes a crash on Ubuntu15.10. See https://bugs.swift.org/browse/SR-2485)
            let tag = "\(Date().timeIntervalSinceReferenceDate)"
            print("\n\n\(tag):\n\t\(input)\n\n\t\(output)")
        }
        
        do {
            let response = try next.respond(to: request)
            output = "Outgoing: '\(response)'"
            return response
        } catch {
            output = "Error processing request: '\(error)'"
            throw error
        }
    }
}
