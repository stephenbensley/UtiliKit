//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SwiftUI
import UIKit

// Displays a generic About page.
public struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    private var info: AboutInfo

    public init(info: some AboutInfo) {
        self.info = info
    }

    public var body: some View {
        NavigationStack {
            Form {
                HStack(alignment: .center) {
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .frame(width: 64, height: 64)
                        .cornerRadius(10)
                        .padding(.trailing, 5)
                    VStack(alignment: .leading) {
                        Text(info.name)
                            .font(.title)
                        Text("Version \(info.version)\n\(info.copyright)")
                            .font(.footnote)
                    }
                }
                
                Section {
                    Link(destination: info.privacyPolicy) {
                        Label("Read the privacy policy", systemImage: "hand.raised")
                    }
                } header: {
                    Text("This app does not collect or share any personal information.")
                }
                .textCase(nil)
                
                Section {
                    Link(destination: info.license) {
                        Label("Read the license", systemImage: "doc.plaintext")
                    }
                    Link(destination: info.sourceCode) {
                        Label("Download the source code", systemImage: "icloud.and.arrow.down")
                    }
                } header: {
                    Text("""
                    The source code for this app has been released under the MIT License and is \
                    hosted on GitHub.
                    """)
                }
                .textCase(nil)
                
                Section {
                    Link(destination: info.writeReview) {
                        Label("Rate this app", systemImage: "star")
                    }
                    ShareLink(item: info.share) {
                        Label("Share this app", systemImage:  "square.and.arrow.up")
                    }
                    Link(destination: info.contact) {
                        Label("Contact the developer", systemImage: "mail")
                    }
                 }
            }
            .navigationTitle("About")
            .toolbar { Button("Done") { dismiss() } }
          }
    }
}

#Preview {
    AboutView(info: MockAboutInfo())
}
