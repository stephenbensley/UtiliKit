//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

// A checker playing piece.
public class Checker: SKSpriteNode {
    public static let indicatorWidth: CGFloat = 5.0
    private static let blackTexture = SKTexture(imageNamed: "blackChecker")
    private static let whiteTexture = SKTexture(imageNamed: "whiteChecker")

    // Color of the checker.
    public let player: PlayerColor
    // True if the checker is selected for the current move.
    public var selected: Bool = false {
        didSet { updateFillColor() }
    }
    // True if the checker is threatened by the current move (i.e., would be captured).
    public var threatened: Bool = false {
        didSet { updateFillColor() }
    }
    // Used to display an indicator 'halo' around the checker.
    private let indicator: SKShapeNode
    
    public init(player: PlayerColor) {
        // Texture is determined by color.
        let texture: SKTexture
        switch player {
        case .black:
            texture = Self.blackTexture
        case .white:
            texture = Self.whiteTexture
        }
        // Assume the checker is a circle that fills the entire texture.
        let checkerRadius = texture.size().width / 2.0

        self.player = player
        self.indicator = SKShapeNode(circleOfRadius: checkerRadius + Self.indicatorWidth)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.zPosition = Layer.checkers
        
        indicator.strokeColor = .clear
        // Put this behind the checker, so it won't intercept touches.
        indicator.zPosition = -1.0
        addChild(indicator)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // threatened takes priority over selected when indicating state.
    private func updateFillColor() {
        switch (selected, threatened) {
        case (false, false):
            indicator.fillColor = .clear
        case (false, true):
            indicator.fillColor = GamePalette.threatened
        case (true, false):
            indicator.fillColor = GamePalette.selected
        case (true, true):
            indicator.fillColor = GamePalette.threatened
        }
    }
}
