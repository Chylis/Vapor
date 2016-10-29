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

extension UserController : Controller {
    
    func register(with builder: RouteGroup<Responder, Droplet>, authFilter: Middleware) {
        builder.group("users") { users in
            users.post("register", handler: register)
            users.post("login", handler: login)
            
            users.group(authFilter) { secure in
                secure.get(handler: allUsers)
                secure.get("me", handler: currentUser)
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
        return try user.converted(to: JSON.self)
    }
}
