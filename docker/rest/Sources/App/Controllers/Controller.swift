//
//  Controller.swift
//  rest
//
//  Created by Magnus Eriksson on 2016-10-29.
//
//

import HTTP
import Vapor
import Routing

protocol Controller {
    /**
     Registers a controller's routes with the received route builder
     - parameter builder: The route builder used to register public routes
     - parameter authFilter: An authfilter used to register routes that require authentication
     */
    func register(with builder: RouteGroup<Responder, Droplet>, authFilter: Middleware)
}
