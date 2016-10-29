//
//  JWTUtil.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-29.
//
//

import Foundation
import Vapor
import VaporJWT

extension JWT {
    
    ///Parses the username from the JWT claims
    func username() -> String? {
        return JWTUtil().parse(parameter: JWTUtil.keyUsername, from: self)
    }
    
    ///Calculates the remaining seconds from the JWT claims
    func remainingSeconds() -> TimeInterval? {
        guard let authorizationTS: TimeInterval = JWTUtil().parse(parameter: JWTUtil.keyExpires, from: self) else {
            return nil
        }
        
        let currentTS = Date().timeIntervalSinceReferenceDate
        let secondsRemaining = authorizationTS - currentTS
        print("JWT token for user \(username() ?? "unknown user") has \(secondsRemaining) seconds remaining")
        return secondsRemaining
    }
}

struct JWTUtil {
    
    private static let secret = "secret123"
    private static let expirationSeconds: TimeInterval = 60
    
    fileprivate static let keyUsername = "username"
    fileprivate static let keyExpires = "expires"
    
    //MARK: - Public
    
    /// Creates a JWT and embeds the received username within the claims
    func makeJWT(username: String) throws -> String {
        let expirationDate = Date().addingTimeInterval(JWTUtil.expirationSeconds)
        let payload = Node.object([JWTUtil.keyUsername: .string(username),
                                   JWTUtil.keyExpires : .number(.double(expirationDate.timeIntervalSinceReferenceDate))])
        let jwt = try JWT(payload: payload, signer: HS256(key: JWTUtil.secret.makeBytes()))
        return try jwt.createToken()
    }
    
    /// Attempts to decode and validate the received JWT string
    func decodeJWT(_ token: String) -> JWT? {
        guard let jwt = try? JWT(token: token),
            let _ = try? jwt.verifySignatureWith(HS256(key: JWTUtil.secret.makeBytes())),
            let secondsRemaining = jwt.remainingSeconds(), secondsRemaining > 0 else {
                return nil
        }
        
        return jwt
    }
    
    //MARK: - Private
    
    /// Attempts to parse the received parameter from the JWT claims
    fileprivate func parse<T>(parameter: String, from jwt: JWT) -> T? {
        guard case let .object(payload) = jwt.payload else {
            return nil
        }
        
        var maybeValue: Any? = nil
        switch parameter {
        case JWTUtil.keyExpires:
            if case let .some(.number(.double(expirationDate))) = payload[parameter] {
                maybeValue = expirationDate
            }
        case JWTUtil.keyUsername:
            if case let .some(.string(username)) = payload[parameter] {
                maybeValue = username
            }
        default:
            return nil
        }
        
        return (maybeValue as? T) ?? nil
    }
}
