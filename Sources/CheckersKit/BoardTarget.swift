//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

// A selectable location on the gameboard.
public class BoardTarget: SKSpriteNode {
    public static let size = CGSize(width: 55.0, height: 55.0)
    public static let zRotation = 0.0
    public static let indicatorRadius = 10.0
    
    // True if the location is currently selected.
    public var selected: Bool = false {
        didSet { indicator.fillColor = selected ? GamePalette.selected : .clear }
    }
    
    // Displays an indicator dot in the center of the location.
    private let indicator: SKShapeNode

    public init(position: CGPoint) {
        self.indicator = SKShapeNode(circleOfRadius: Self.indicatorRadius)
        super.init(texture: nil, color: .clear, size: Self.size)
        self.position = position
        self.zPosition = Layer.targets
        self.zRotation = Self.zRotation

        indicator.strokeColor = .clear
        // Put this behind the target, so it won't intercept touches.
        indicator.zPosition = -1.0
        addChild(indicator)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
