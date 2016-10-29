//
//  JWTFilter.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-29.
//
//

import HTTP
import Vapor
import VaporJWT

final class JWTFilter: Middleware {
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let bearer = request.headers["Authorization"], bearer.hasPrefix("Bearer ") else {
            throw Abort.custom(status: .unauthorized, message: "Missing bearer token")
        }
        
        let components = bearer.components(separatedBy: " ")
        guard let token = components.last,
            let jwt = JWTUtil().decodeJWT(token),
            let username = jwt.username() else {
            throw Abort.custom(status: .unauthorized, message: "Invalid JWT")
        }
        
        //Populate user in request so that the final endpoint has access to it
        request.storage["username"] = username
        
        return try next.respond(to: request)
    }
}
