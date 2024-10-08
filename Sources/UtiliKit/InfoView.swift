//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SwiftUI

// Displays a page of markdown.
public struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    private let title: String
    private let contents: Text
    
    public init(title: String) {
        self.init(title: title, fromResource: title)
    }
    
    public init(title: String, fromResource name: String) {
        self.init(title: title, contents: Self.load(fromResource: name))
    }
    
    public init(title: String, contents: String) {
        self.title = title
        self.contents = Self.convertToText(contents)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                contents
            }
            .padding()
            .navigationTitle(title)
            .toolbar { Button("Done") { dismiss() } }
        }
    }
    
    // Since Swift doesn't support images in markdown, we implement our own logic where
    // we replace |systemName| with the corresponding SF Symbol.
    private static func convertToText(_ contents: String) -> Text {
        contents.split(separator: "|").enumerated().reduce(Text("")) { result, token in
            if token.offset % 2 == 0 {
                // Even tokens are markdown
                result + Text(LocalizedStringKey(String(token.element)))
            } else {
                // Odd tokens are SF Symbol names
                result + Text(Image(systemName: "\(token.element)"))
            }
        }
    }
    
    private static func load(fromResource name: String) -> String {
        guard let path = Bundle.main.path(forResource: name, ofType: "md") else {
            fatalError("Failed to locate \(name).md in bundle.")
        }
        guard let contents = try? String(contentsOfFile: path) else {
            fatalError("Failed to load \(name).md from bundle.")
        }
        return contents
    }
}

#Preview {
    InfoView(
        title: "InfoView Preview",
        contents: "Your content will appear here. This is a symbol: |gearshape|"
    )
}
