//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

public class Checker: SKSpriteNode {
    public static let indicatorWidth: CGFloat = 5.0
    private static let blackTexture = SKTexture(imageNamed: "blackChecker")
    private static let whiteTexture = SKTexture(imageNamed: "whiteChecker")

    public let player: PlayerColor
    public var selected: Bool = false {
        didSet { updateFillColor() }
    }
    public var threatened: Bool = false {
        didSet { updateFillColor() }
    }
    private let indicator: SKShapeNode
    
    public init(player: PlayerColor, position: CGPoint) {
        self.player = player
        
        let texture: SKTexture
        switch player {
        case .black:
            texture = Self.blackTexture
        case .white:
            texture = Self.whiteTexture
        }
        
        let checkerRadius = texture.size().width / 2.0
        self.indicator = SKShapeNode(circleOfRadius: checkerRadius + Self.indicatorWidth)
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.position = position
        self.zPosition = Layer.checkers
        
        indicator.strokeColor = .clear
        indicator.zPosition = -1.0
        addChild(indicator)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
