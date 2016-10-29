//
//  Request+User.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-29.
//
//

import HTTP

extension Request {
    
    /// Returns the user associated to the request. Will return nil if the request isn't authenticated.
    func currentUser() -> AppUser? {
        //FIXME: Place db logic in a UserManager or similar
        guard let username = storage["username"] as? String,
        let user = try? AppUser.query().filter("username", username).first() else {
            return nil
        }
        
        return user
    }
}
