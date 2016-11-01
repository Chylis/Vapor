//
//  UserController.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-29.
//
//

import HTTP
import Vapor
import BCrypt
import Routing
import Foundation

extension UserController : Controller {
    
    func register<D>(with builder: RouteGroup<Responder, D>, authFilter: Middleware) {
        builder.group("users") { users in
            users.post("register", handler: register)
            users.post("login", handler: login)
            
            users.group(authFilter) { secure in
                secure.get(handler: allUsers)
                secure.get("me", handler: currentUser)
                secure.post("me", handler: updateUserAvatar)
                secure.get(":username", handler: user)
            }
        }
    }
}

final class UserController {
    
    let salt = "$2a$10$customsaltdigest"
    
    /**
     Creates and persists a user to the database
     - parameter request: The http request, containing 'username' and 'password'
     - returns: The newly created user
     - throws: 'Abort' error if params username or password are missing or if the username already exists
     */
    fileprivate func register(_ request: Request) throws -> ResponseRepresentable {
        guard let username = request.json?["username"]?.string else {
            throw Abort.custom(status: .badRequest, message: "username is required")
        }
        guard let password = request.json?["password"]?.string else {
            throw Abort.custom(status: .badRequest, message: "password is required")
        }
        //FIXME: Place db logic in a UserManager or similar
        guard try AppUser.query().filter("username", username).run().isEmpty else {
            throw Abort.custom(status: .conflict, message: "username is already taken")
        }
        
        var user = try AppUser(username: username, password: BCrypt.hash(password: password, salt: BCryptSalt(string: salt)))
        try user.save()
        let jwt = try JWTUtil().makeJWT(username: username)
        
        return try Response(status: .ok, json: JSON(Node([
            "token": Node(jwt),
            "user": user.makeNode()
            ])))
    }
    
    /**
     Creates a JWT for the received username
     - parameter request: The http request, containing 'username' and 'password'
     - returns: A JWT containing the username
     - throws: 'Abort' error if params username or password are missing or if there is no user with the received username and password
     */
    fileprivate func login(_ request: Request) throws -> ResponseRepresentable {
        guard let username = request.json?["username"]?.string else {
            throw Abort.custom(status: .badRequest, message: "username is required")
        }
        guard let password = request.json?["password"]?.string else {
            throw Abort.custom(status: .badRequest, message: "password is required")
        }
        //FIXME: Place db logic in a UserManager or similar
        guard let saltedPassword = try? BCrypt.hash(password: password, salt: BCryptSalt(string: salt)),
            let user = try AppUser.query().filter("username", username).filter("password", saltedPassword).first() else {
                throw Abort.notFound
        }
        
        let jwt = try JWTUtil().makeJWT(username: username)
        return try Response(status: .ok, json: JSON(Node([
            "token": Node(jwt),
            "user": user.makeNode()
            ])))
    }
    
    
    /// Returns all users in JSON
    fileprivate func allUsers(_ request: Request) throws -> ResponseRepresentable {
        //FIXME: Place db logic in a UserManager or similar
        return try AppUser.all().makeNode().converted(to: JSON.self)
    }
    
    /// Returns the user associated with the received (authenticated) request
    fileprivate func currentUser(_ request: Request) throws -> ResponseRepresentable {
        guard let user = request.currentUser() else {
            throw Abort.custom(status: .internalServerError, message: "Unable to find user inside authenticated endpoint")
        }
        return user
    }
    
    /// Returns the user with username 'username'
    fileprivate func user(_ request: Request) throws -> ResponseRepresentable {
        guard let username = request.parameters["username"] else {
            throw Abort.custom(status: .badRequest, message: "username is required")
        }
        guard let user = try AppUser.query().filter("username", username).first() else {
            throw Abort.notFound
        }
        return user
    }
    
    fileprivate func updateUserAvatar(_ request: Request) throws -> ResponseRepresentable {
        guard var user = request.currentUser() else {
            throw Abort.custom(status: .internalServerError, message: "Unable to find user inside authenticated endpoint")
        }
        guard let base64Bytes = request.body.bytes,
            let base64String = try? String(bytes: base64Bytes) else {
            throw Abort.custom(status: .badRequest, message: "missing data")
        }
        
        user.base64Avatar = base64String
        try user.save()
        
        return Response(status: .ok)
    }
}
