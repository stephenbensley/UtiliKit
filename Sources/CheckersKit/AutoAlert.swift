//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

public class AutoAlert: SKNode {
    public static let size = CGSize(width: 225.0, height: 75.0)
    public static let cornerRadius:CGFloat = 18.0
    public static let fillColor = GamePalette.background
    public static let lineWidth: CGFloat = 5.0
    public static let fontName = "Helvetica"
    public static let fontSize: CGFloat = 20.0
    
    public init(_ label: String) {
        super.init()
        self.alpha = 0.0
        self.zPosition = Layer.alerts
        
        let background = SKShapeNode(rectOf: Self.size, cornerRadius: Self.cornerRadius)
        background.fillColor = Self.fillColor
        background.lineWidth = Self.lineWidth
        addChild(background)
        
        let text = SKLabelNode(text: label)
        text.fontName = Self.fontName
        text.fontSize = Self.fontSize
        text.verticalAlignmentMode = .center
        background.addChild(text)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func display(completion: @escaping () -> Void) {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.50),
            SKAction.removeFromParent()
        ]),
            completion: completion
        )
    }
}
