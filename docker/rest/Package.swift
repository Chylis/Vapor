import PackageDescription

let package = Package(
    name: "rest",
    dependencies: [
      .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 0),
      .Package(url:"https://github.com/siemensikkema/vapor-jwt.git", majorVersion: 0, minor: 4)
    ]
)
