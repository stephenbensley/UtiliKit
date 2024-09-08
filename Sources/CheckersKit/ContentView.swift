//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/CheckersKit/blob/main/LICENSE.
//

import SwiftUI
import SpriteKit

// Main content view for a checkers game. Switches between the main menu implemented in SwiftUI
// and the game scene implemented in SpriteKit.
public struct ContentView: View {
    // Used to trigger saving state when app goes inactive.
    @Environment(\.scenePhase) private var scenePhase
    // Triggers visibility of the game vs. the main menu.
    @State private var showGame = false
    // Provided by the enclosing app.
    @State private var game: CheckersGame

    public init(game: some CheckersGame) {
        self.game = game
    }

    public var body: some View {
        ZStack {
            Color.background
            if showGame {
                GeometryReader { proxy in
                    SpriteView(scene: game.getScene(size: proxy.size, exitGame: exitGame))
                }
            } else {
                MainMenu(game: game, showGame: $showGame.animation())
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive { game.save() }
        }
    }
     
    private func exitGame() {
        withAnimation { showGame = false }
    }
}

#Preview {
    ContentView(game: MockGame())
}
