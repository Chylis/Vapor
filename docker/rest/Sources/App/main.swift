import Vapor

let drop = Droplet()

drop.get("/test") { _ in
  return "Testing mag"
}

drop.run()
