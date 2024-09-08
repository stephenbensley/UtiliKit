//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/CheckersKit/blob/main/LICENSE.
//

import SpriteKit

// A selectable location on the gameboard.
public class BoardTarget: SKSpriteNode {
    // Displays an indicator dot in the center of the location.
    private let indicator: SKShapeNode

    // True if the location is currently selected.
    public var selected: Bool = false {
        didSet { indicator.fillColor = selected ? SKColor.selected : .clear }
    }

    public init(sideLength: CGFloat, zRotation: CGFloat = 0.0) {
        self.indicator = SKShapeNode(circleOfRadius: 0.2 * sideLength)
        super.init(
            texture: nil,
            color: .clear,
            size: .init(width: sideLength, height: sideLength)
        )
        self.zPosition = Layer.targets
        self.zRotation = zRotation
        self.indicator.strokeColor = .clear
        // Put the indicator behind the target, so it won't intercept touches.
        self.indicator.zPosition = -1.0
        addChild(self.indicator)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
