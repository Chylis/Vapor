//
//  AppUser.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-28.
//
//

import Foundation
import Vapor

final class AppUser: Model {
    
    //MARK: - Custom properties
    
    let username: String
    var base64Avatar: String?
    
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
    
    //Create the model from the persisted data.
    init(node: Node, in context: Context) throws {
        id = nil
        username = try node.extract("username")
        password = try node.extract("password")
        base64Avatar = try node.extract("avatar")
    }
    
    func makeNode(context: Context) throws -> Node {
        let array = [
            "id": id,
            "username":username.makeNode(),
            "password":password.makeNode(),
            "avatar": base64Avatar?.makeNode()
        ]
        return try Node(node: array)
    }
    
    //MARK: - Preparation conformance
    
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}
