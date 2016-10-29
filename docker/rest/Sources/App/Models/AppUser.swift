//
//  AppUser.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-28.
//
//

import Vapor

final class AppUser: Model {
    
    //MARK: - Custom properties
    
    let username: String
    //FIXME: password is returned to client through API
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    //MARK: - Entity conformance
    
    var id: Node?
    var exists: Bool = false
    
    //MARK: - NodeConvertible conformance
    
    init(node: Node, in context: Context) throws {
        id = nil
        username = try node.extract("username")
        password = try node.extract("password")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username":username,
            "password":password
            ])
    }
    
    //MARK: - Preparation conformance
    
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}
