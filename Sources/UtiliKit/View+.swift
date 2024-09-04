//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SwiftUI

extension View {
    // View modifier to set the color of the navigation bar title. This doesn't seem to be
    // exposed through SwiftUI yet.
    func navigationBarTitleColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
        return self
    }
}

#Preview {
    struct TitleColorPreview: View {
        var body: some View {
            NavigationStack {
                Text("Hello, world!")
                    .navigationTitle("Title")
                    .navigationBarTitleColor(.purple)
            }
        }
    }
    return TitleColorPreview()
}
