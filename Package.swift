// swift-tools-version:5.3
/*
 This above line is a must. It looks like a comment but it is a must and exactly like this. It declares:
    - The version of PackageDescription(see: https://developer.apple.com/documentation/swift_packages/package)
    - The Swift language compatibility version to process the Manifest(this file 'Package.wift' is called 'manifest')
    - The required minimum version of the Swift tools to use the package
 */
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NumericTextField",
    /*
     By default swift packages are usually multy platforms. We want this package to only work on IOS plaform. Hence we are specify the
     plaform explicitely here. We want this framwork to work only on IOS platform instead(mac, linux etc..) and we want the minimum
     version to be IOS 13 and Up.
     If you do not specify the framework here explicitely, then in your code, you will have to put an 'if' check everywhere to
     see if you are running this code on IOS or mac or other supported platform before you run a specify logic available only
     on specific platform.
     For example, UIKit is only available on IOS, if you don't specify 'platforms' here to be iOS, then in your code, you need to first
     add an 'if' check to see 'UIKit' can be used or not. like this:
     #if canImport(UIKit)
     import UIKit
        //your code for UIkit
     #endif

     see https://developer.apple.com/documentation/xcode/creating_a_standalone_swift_package_with_xcode
    */    
    platforms: [.iOS(PackageDescription.SupportedPlatform.IOSVersion.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NumericTextField",
            targets: ["NumericTextField"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NumericTextField",
            dependencies: []
        ),
        .testTarget(
            name: "NumericTextFieldTests",
            dependencies: ["NumericTextField"]),
    ]
)
