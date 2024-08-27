//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

#if os(macOS)
public typealias BoardGameImage = NSImage
#else
public typealias BoardGameImage = UIImage
#endif

public class RollingDie: SKSpriteNode {
    public static let anchorPoint = CGPoint(x: 0.5, y: sqrt(3.0)/6.0)
    public static let rollDuration: CGFloat = 0.75
    public static let rollRotations: CGFloat = 2
    private static let dieTextures = loadTextures()
    
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
    
    public func roll(newValue: Int, completion block: @escaping () -> Void) {
        precondition(newValue < Self.dieTextures.count)
        run(
            SKAction.sequence([
                SKAction.rotate(
                    byAngle: -2.0 * .pi * Self.rollRotations,
                    duration: Self.rollDuration
                ),
                SKAction.setTexture(Self.dieTextures[newValue])
            ]),
            completion: block
        )
    }
    
    private static func loadTextures() -> [SKTexture] {
        var result = [SKTexture]()
        var roll = 0
        while true {
            let name = "die\(roll)"
            guard let image = BoardGameImage(named: name) else { break }
            result.append(.init(image: image))
            roll += 1
        }
        return result
    }
}

public class MultiComplete {
    private var outstanding: Int
    private var completion: (() -> Void)

    public init(waitCount: Int, completion: @escaping () -> Void) {
        self.outstanding = waitCount
        self.completion = completion
    }

    public func complete() {
        assert(outstanding > 0)
        outstanding -= 1
        guard outstanding == 0 else { return }
        completion()
    }
}

public class RollingDice: SKShapeNode {
    public static let lineWidth: CGFloat = 3.0
    public static let cornerRadius: CGFloat = 2.0
    public static let padding: CGFloat = 5.0
    public static let spacing: CGFloat = 10.0
    
    public enum Orientation {
        case horizontal
        case vertical
    }
    public typealias OnComplete = () -> Void
    
    
    private let indicator: SKShapeNode
    private let dice: [RollingDie]
    private var newValues: [Int]? = nil
    private var completion: (() -> Void)? = nil
 
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { }
    }
    
    public init(diceCount: Int, orientation: Orientation) {
        assert(diceCount > 0)
        
        let size = Self.size(diceCount: diceCount, orientation: orientation)
        self.indicator = SKShapeNode(rectOf: size, cornerRadius: Self.cornerRadius)
        
        let positions = Self.positions(diceCount: diceCount, orientation: orientation)
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
    
    public func roll(newValues: [Int], completion: @escaping () -> Void) {
        let multiComplete = MultiComplete(waitCount: dice.count, completion: completion)
        zip(dice, newValues).forEach { die, roll in
            die.roll(newValue: roll, completion: multiComplete.complete)
        }
    }

    public func rollOnTap(newValues: [Int], completion: @escaping () -> Void) {
        self.indicator.strokeColor = GamePalette.selected
        self.newValues = newValues
        self.completion = completion
    }

    private func touchDown(location: CGPoint) {
        guard let newValues = self.newValues, let completion = self.completion else { return }
        self.newValues = nil
        self.completion = nil

        self.indicator.strokeColor = .clear
        roll(newValues: newValues, completion: completion)
    }
    
    private static func length(diceCount: Int, diceLength: Double) -> Double {
        diceLength * Double(diceCount) + spacing * Double(diceCount - 1) + 2.0 * padding
    }
    
    private static func positions(diceCount: Int, orientation: Orientation) -> [CGPoint] {
        let dieSize = RollingDie.size
        let anchor = RollingDie.anchorPoint
        
        let stepX, minX, stepY, minY: Double
        switch orientation {
        case .horizontal:
            stepX = dieSize.width + spacing
            minX  = -0.5 * Double(diceCount - 1)  * stepX + dieSize.width * (anchor.x - 0.5)
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
    
    private static func size(diceCount: Int, orientation: Orientation) -> CGSize {
        let dieSize = RollingDie.size
        switch orientation {
        case .horizontal:
            return .init(
                width: Self.length(diceCount: diceCount, diceLength: dieSize.width),
                height: Self.length(diceCount: 1, diceLength: dieSize.height)
            )
        case .vertical:
            return .init(
                width: Self.length(diceCount: 1, diceLength: dieSize.width),
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
