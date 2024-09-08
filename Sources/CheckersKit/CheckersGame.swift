//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/CheckersKit/blob/main/LICENSE.
//

import SpriteKit
import UtiliKit

// Exposes the game-specific properties and methods consumed by the main menu and its descendants.
public protocol CheckersGame: AboutInfo {
    // Return the game scene. SKScene is isolated to MainActor.
    @MainActor
    func getScene(size: CGSize, exitGame: @escaping () -> Void) -> SKScene
    // Begin a new game.
    func newGame(white: PlayerType, black: PlayerType) -> Void
    // Save game state.
    func save() -> Void
}

// Useful for previews
class MockGame: CheckersGame {
    // AboutInfo
    public var appStoreId: Int = 1631745251
    public var copyright: String = "© 2024 Stephen E. Bensley"
    public var description: String = "This is a mock app for testing purposes."
    public var gitHubAccount: String = "stephenbensley"
    public var gitHubRepo: String = "UrCoach"

    // CheckersGame
    public func getScene(size: CGSize, exitGame: @escaping () -> Void) -> SKScene { .init() }
    public func newGame(white: PlayerType, black: PlayerType) { }
    public func save() { }
}
