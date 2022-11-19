# Installation

Read how to install *Web* library and link it to your projects.

## Swift Package Manager

The *Web* library is available via [Swift Package Manager](https://swift.org/package-manager/).

##### Linking to an Xcode project

- Go to `File` -> `Add Packages...` 
- Type package URL [https://github.com/InstrumentBox/Network](https://github.com/InstrumentBox/Network)
- Select `Network` package, specify dependency rule, and click `Add Package`
- Select `Web` and `WebCore` targets and click `Add Package`

##### Linking to a Swift package

Add the following lines to your `Package.swift` file:

```swift
let package = Package(
   ...,
   dependencies: [
      ...,
      .package(name: "Network", url: "https://github.com/InstrumentBox/Network", from: "3.0.0")
   ],
   targets: [
      .target(..., dependencies: [
         .product(name: "Web", package: "Network"),
         .product(name: "WebCore", package: "Network")
      ]
   ]
   ...
)
```

## Git Submodule

- Open Terminal and `cd` to your project top-level directory

- Add *Network* package as git [submodule](https://git-scm.com/docs/git-submodule) by running the
  following command

```sh
$ git submodule add https://github.com/InstrumentBox/Network.git
```

- Go to Xcode and select `File` -> `Add Packages...`
- Click `Add Local...`
- Select `Network` directory
- Next, select your application project in the Project Navigator (blue project icon) to navigate 
  to the target configuration window and select the application target under the "Targets" heading 
  in the sidebar
- In the tab bar at the top of that window open the "General" panel.
- Click on the `+` button under the "Frameworks, Libraries, and Embedded Content" section
- Select `Web` and `WebCore` libraries

## Manual Installation

If you prefer not to use Swift Package Manager or git submodules, you can  integrate  *Web* into 
your project manually.

- Download the repository at [https://github.com/InstrumentBox/Network](https://github.com/InstrumentBox/Network)
- Unzip archive
- Copy all `*.swift` files from `Sources/Web` to your project
- Go to Xcode and select `File` -> `Add Files to "<Project Name>"...`
- Select recently copied files

## Carthage

Carthage is not supported. From now on, Swift Package Manager should be the preferred dependency 
management tool.

## CocoaPods

CocoaPods are not supported. From now on, Swift Package Manager should be the preferred dependency 
management tool.
