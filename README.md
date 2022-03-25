# OctoSearch

Searching GitHub repositories through an iOS app.

## Installation

This project uses CocoaPods to manage dependencies.
You will need a recent version of the CocoaPods library to set up the project. [Install CocoaPods](https://cocoapods.org)

To set up the project, run `pod install` in the root directory.

Make sure to always open the Xcode workspace instead of the project file when building the project:
    
    $ open OctoSearch.xcworkspace

## Notes

The app issues anonymous requests to the GitHub API, which is rate limited to around 10 requests per minute.


## ⚠️ Xcode 13.3

Please bear in mind that the current version of the test framework does not work
properly with Xcode 13.3. [issue](https://github.com/Quick/Quick/issues/1123)

It is recommended to open this project in Xcode 13.2.
