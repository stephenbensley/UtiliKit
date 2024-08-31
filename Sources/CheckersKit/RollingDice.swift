//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit
import UtiliKit

#if os(macOS)
public typealias BoardGameImage = NSImage
#else
public typealias BoardGameImage = UIImage
#endif

// Visual representation of a rolling die.
public class RollingDie: SKSpriteNode {
    public static let anchorPoint = CGPoint(x: 0.5, y: sqrt(3.0)/6.0)
    public static let rollDuration: CGFloat = 0.7
    public static let rollRotations: CGFloat = 2
    private static let dieTextures = loadTextures()
    
    // Size of the die -- assumes all textures are the same size.
    public static var size: CGSize { dieTextures.first?.size() ?? .init() }
    
    public init(position: CGPoint) {
        if let texture = Self.dieTextures.randomElement() {
            super.init(texture: texture, color: .clear, size: texture.size())
        } else {
            super.init()
        }
        
        self.position = position
        self.anchorPoint = Self.anchorPoint
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Animates the die rolling.
    public func roll(newValue: Int, completion: @escaping () -> Void) {
        precondition(newValue < Self.dieTextures.count)
        let texture = Self.dieTextures[newValue]
        run(
            SKAction.sequence([
                SKAction.rotate(
                    byAngle: -2.0 * .pi * Self.rollRotations,
                    duration: Self.rollDuration
                ),
                SKAction.setTexture(texture)
            ]),
            completion: completion
        )
    }
    
    // Update the value without animation.
    public func setValue(_ newValue: Int) {
        precondition(newValue < Self.dieTextures.count)
        texture = Self.dieTextures[newValue]
    }

    private static func loadTextures() -> [SKTexture] {
        var result = [SKTexture]()
        var value = 0
        while true {
            let name = "die\(value)"
            guard let image = BoardGameImage(named: name) else { break }
            result.append(.init(image: image))
            value += 1
        }
        return result
    }
}

// Visual representation of a set of rolling dice.
public class RollingDice: SKShapeNode {
    public static let lineWidth: CGFloat = 3.0
    public static let cornerRadius: CGFloat = 3.0
    public static let padding: CGFloat = 10.0
    public static let spacing: CGFloat = 10.0
    
    // The dice are presented in a line, either horizontal or vertical.
    public enum Orientation {
        case horizontal
        case vertical
    }
    
    // Used to highlight the dice -- useful to indicate whose turn it is.
    private let indicator: SKShapeNode
    // Individual RollingDie making up the set.
    private let dice: [RollingDie]
 
    public var selected: Bool {
        get { indicator.strokeColor != .clear }
        set { indicator.strokeColor = newValue ? GamePalette.selected : .clear }
    }

    public init(diceCount: Int, orientation: Orientation) {
        assert(diceCount > 0)
        
        // Compute the size of the rectangle needed to hold all the dice.
        let size = Self.size(diceCount: diceCount, orientation: orientation)
        // Compute the positions of the dice within the rectangle.
        let positions = Self.positions(diceCount: diceCount, orientation: orientation)
        
        self.indicator = SKShapeNode(rectOf: size, cornerRadius: Self.cornerRadius)
        self.dice = positions.map { RollingDie(position: $0) }
        super.init()
        self.zPosition = Layer.dice
        
        self.indicator.lineWidth = Self.lineWidth
        self.indicator.strokeColor = .clear
        addChild(self.indicator)
        
        for die in dice { self.indicator.addChild(die) }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Roll the dice with animation.
    public func roll(newValues: [Int], completion: @escaping () -> Void) {
        let multiComplete = MultiComplete(waitCount: dice.count, completion: completion)
        zip(dice, newValues).forEach { die, roll in
            die.roll(newValue: roll, completion: multiComplete.complete)
        }
    }

    // Update the values without animation.
    public func setValues(_ newValues: [Int]) {
        zip(dice, newValues).forEach {  $0.setValue($1) }
    }

    // Calculates the length of a row or column of dice accounting for spacing & padding.
    private static func length(diceCount: Int, diceLength: Double) -> Double {
        diceLength * Double(diceCount) + spacing * Double(diceCount - 1) + 2.0 * padding
    }
    
    // Calculates the relative positions of the dice within the dice group.
    private static func positions(diceCount: Int, orientation: Orientation) -> [CGPoint] {
        let dieSize = RollingDie.size
        let anchor = RollingDie.anchorPoint
        
        let stepX, minX, stepY, minY: Double
        switch orientation {
        case .horizontal:
            stepX = dieSize.width + spacing
            minX  = -0.5 * Double(diceCount - 1) * stepX + dieSize.width * (anchor.x - 0.5)
            stepY = 0.0
            minY  = 0.0
            
        case .vertical:
            stepX = 0.0
            minX  = 0.0
            stepY = dieSize.height + spacing
            minY  = -0.5 * Double(diceCount - 1) * stepY + dieSize.height * (anchor.y - 0.5)
        }
        
        return (0..<diceCount).map {
            CGPoint(
                x: minX + Double($0) * stepX,
                y: minY + Double($0) * stepY
            )
        }
    }
    
    // Calculates the size of the rectangle needed to hold all the dice.
    private static func size(diceCount: Int, orientation: Orientation) -> CGSize {
        let dieSize = RollingDie.size
        switch orientation {
        case .horizontal:
            return .init(
                width:  Self.length(diceCount: diceCount, diceLength: dieSize.width),
                height: Self.length(diceCount: 1,         diceLength: dieSize.height)
            )
        case .vertical:
            return .init(
                width:  Self.length(diceCount: 1,         diceLength: dieSize.width),
                height: Self.length(diceCount: diceCount, diceLength: dieSize.height)
            )
        }
    }
}
