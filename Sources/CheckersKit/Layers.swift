//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

// Defines the zPosition for various uses.
public struct Layer {
    // Gameboard image
    public static let gameboard: CGFloat =  0.0
    // Any user controls, such as buttons
    public static let controls:  CGFloat =  0.0
    // Tappable targets
    public static let targets:   CGFloat = 10.0
    // Stationary checkers
    public static let checkers:  CGFloat = 20.0
    // Dice (if any)
    public static let dice:      CGFloat = 20.0
    // Captured checker being moved off the board
    public static let captured:  CGFloat = 30.0
    // Moving checker
    public static let moving:    CGFloat = 40.0
    // Text alert displayed to the user
    public static let alerts:    CGFloat = 50.0
}

public extension SKAction {
    @MainActor
    static func setLayer(_ layer: CGFloat, onTarget node: SKNode) -> SKAction {
        SKAction.run { [weak node] in node?.zPosition = layer }
    }
}
