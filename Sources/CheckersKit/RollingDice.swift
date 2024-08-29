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
    
    // The value of the die. This is the index into the dieTextures array, not the human-
    // readable value.
    public var value = 0 {
        didSet {
            precondition(value < Self.dieTextures.count)
            texture = Self.dieTextures[value]
        }
    }
    
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
        run(
            SKAction.sequence([
                SKAction.rotate(
                    byAngle: -2.0 * .pi * Self.rollRotations,
                    duration: Self.rollDuration
                ),
                SKAction.run { [unowned self] in self.value = newValue }
            ]),
            completion: completion
        )
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
    public static let cornerRadius: CGFloat = 2.0
    public static let padding: CGFloat = 5.0
    public static let spacing: CGFloat = 10.0
    
    // The dice are presented in a line, either horizontal or vertical.
    public enum Orientation {
        case horizontal
        case vertical
    }
    public typealias OnComplete = () -> Void
    
    // Used to highlight the dice when waiting for user input.
    private let indicator: SKShapeNode
    // Individual RollingDie making up the set.
    private let dice: [RollingDie]
    // New values that will be set when the user initiates a roll.
    private var newValues: [Int]? = nil
    // Callback invoked when the roll animation is complete.
    private var completion: (() -> Void)? = nil
 
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { }
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
    
    // Roll the dice immediately.
    public func roll(newValues: [Int], completion: @escaping () -> Void) {
        let multiComplete = MultiComplete(waitCount: dice.count, completion: completion)
        zip(dice, newValues).forEach { die, roll in
            die.roll(newValue: roll, completion: multiComplete.complete)
        }
    }

    // Roll the dice once the user taps on them.
    public func rollOnTap(newValues: [Int], completion: @escaping () -> Void) {
        self.indicator.strokeColor = GamePalette.selected
        self.newValues = newValues
        self.completion = completion
    }

    // Update the values without animation.
    public func setValues(_ newValues: [Int]) {
        zip(dice, newValues).forEach {  $0.value = $1 }
    }

    // Handles the user touching the dice.
    private func touchDown(location: CGPoint) {
        // Save what we need.
        guard let newValues = newValues, let completion = completion else { return }
        
        // Stop accepting input.
        self.indicator.strokeColor = .clear
        self.newValues = nil
        self.completion = nil

        // Trigger the animation.
        roll(newValues: newValues, completion: completion)
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
    
#if os(macOS)
    public override func mouseDown(with event: NSEvent) {
        touchDown(location: event.location(in: self))
    }
#else
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(location: t.location(in: self))}
    }
#endif
}
