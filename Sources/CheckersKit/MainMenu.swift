// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/CheckersKit/blob/main/LICENSE.
//

import SwiftUI
import UtiliKit

// An item in the main menu. Designed to mimic the appearance of SKButton.
public struct MenuItem: View {
    private let text: LocalizedStringKey
    private let action: () -> Void
    
    public init(text: LocalizedStringKey, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom("Helvetica", fixedSize: 20))
                .frame(width: 250)
                .padding()
                .foregroundStyle(.black)
                .background(Color.gameBoardFill)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gameBoardStroke, lineWidth: 4)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(2)
    }
}

// Presents the main menu of options for the user to choose from.
public struct MainMenu: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.openURL) private var openURL
    private var game: CheckersGame
    @Binding private var showGame: Bool
    @State private var showHelp = false
    @State private var showAbout = false
    
    private var scale: CGFloat { sizeClass == .compact ? 1.0 : 1.5 }
    
    public init(game: some CheckersGame, showGame: Binding<Bool>) {
        self.game = game
        self._showGame = showGame
    }
    
    public var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(game.name)
                    .font(.custom("Helvetica-Bold", fixedSize: 36))
                    .foregroundStyle(.white)
                    .padding(.bottom, 2)
                Text(game.description)
                    .font(.custom("Helvetica", fixedSize: 18))
                    .foregroundStyle(.white)
                    .padding(.bottom)
                    .frame(maxWidth: 350)
                MenuItem(text: "White vs. Computer") {
                    game.newGame(white: .human, black: .computer)
                    showGame = true
                }
                MenuItem(text: "Black vs. Computer") {
                    game.newGame(white: .computer, black: .human)
                    showGame = true
                }
                MenuItem(text: "Player vs. Player") {
                    game.newGame(white: .human, black: .human)
                    showGame = true
                }
                MenuItem(text: "Resume Game") {
                    showGame = true
                }
                MenuItem(text: "How to Play") {
                    showHelp = true
                }
                MenuItem(text: "About") {
                    showAbout = true
                }
            }
            .scaleEffect(scale, anchor: .center)
            Spacer()
            Spacer()
        }
        .sheet(isPresented: $showHelp) {
            InfoView(title: "How to Play", fromResource: "Help")
        }
        .sheet(isPresented: $showAbout) {
            AboutView(info: game)
        }
    }
}

#Preview {
    struct MainMenuPreview: View {
        @State var showGame = false
        var body: some View {
            ZStack {
                Color.background
                MainMenu(game: MockGame(), showGame: $showGame)
            }
            .ignoresSafeArea()
        }
    }
    return MainMenuPreview()
}
