import HTTP
import Vapor
import Fluent
import Routing

//Setup application
let database = Database(MemoryDriver())
let drop = Droplet(database: database, preparations: [AppUser.self])

//Setup routes
let apiVersion = "v1"
let authFilter = JWTFilter()
let routeBuilder: RouteGroup<Responder, Droplet> = drop.grouped(apiVersion)
let controllers: [Controller] = [UserController()]
for controller in controllers {
    controller.register(with: routeBuilder, authFilter: authFilter)
}

//Start application
drop.run()
