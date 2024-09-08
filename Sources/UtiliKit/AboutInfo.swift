//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import Foundation
import SwiftUI

// Exposes app-specific properties for the app's about page or similar scenarios. This protocol
// doesn't need to run on the MainActor per se, but types that implement this protocol frequently
// will, and it's a pain to implement a non-isolated protocol from an isolated type.
@MainActor
public protocol AboutInfo {
    // ID used to identify the app on the AppStore
    var appStoreId: Int { get }
   // Copyright notice
    var copyright: String { get }
    // Brief description suitable for a sub-title.
    var description: String { get }
    // GitHub account that hosts the repo
    var gitHubAccount: String { get }
    // GitHub repo -- just the repo name, not the full URL
    var gitHubRepo: String { get }
}

// Additional info that can be derived automatically.
public extension AboutInfo {
    var name: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }

    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

#if os(macOS)
    var icon: Image { Image(nsImage: NSImage(named: "AppIcon") ?? NSImage()) }
#else
    var icon: Image { Image(uiImage: UIImage(named: "AppIcon") ?? UIImage()) }
#endif

    var contact: URL {
        .init(string: "https://github.com/\(gitHubAccount)")!
    }

    // Assumes the license file is called LICENSE and is located at the root of the repo.
    var license: URL {
        .init(string: "https://github.com/\(gitHubAccount)/\(gitHubRepo)/blob/main/LICENSE")!
    }
    
    // Assumes the privacy policy is called privacy.html and has been published to the root of
    // github.io.
    var privacyPolicy: URL {
        .init(string: "https://\(gitHubAccount).github.io/\(gitHubRepo)/privacy.html")!
    }
    
    var share: URL {
        .init(string: "https://apps.apple.com/us/app/id\(appStoreId)")!
    }
    
    var sourceCode: URL {
        .init(string: "https://github.com/\(gitHubAccount)/\(gitHubRepo)")!
    }
    
    var writeReview: URL {
        .init(string: "https://apps.apple.com/us/app/id\(appStoreId)?action=write-review")!
    }
}

// Useful for previews and testing.
public struct MockAboutInfo: AboutInfo {
    public var appStoreId: Int = 1631745251
    public var copyright: String = "© 2024 Stephen E. Bensley"
    public var description: String = "This is a mock app for testing purposes."
    public var gitHubAccount: String = "stephenbensley"
    public var gitHubRepo: String = "UrCoach"
 }
