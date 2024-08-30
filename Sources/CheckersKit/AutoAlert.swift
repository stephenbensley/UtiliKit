//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

// Displays a text alert that automatically fades out after a short time.
public class AutoAlert: SKNode {
    public static let cornerRadius:CGFloat = 15.0
    public static let fillColor = GamePalette.background
    public static let lineWidth: CGFloat = 4.0
    public static let fontName = "Helvetica"
    public static let fontSize: CGFloat = 20.0
    public static let padding = 25.0
    
    public init(_ text: String) {
        super.init()
        self.alpha = 0.0
        self.zPosition = Layer.alerts
        
        let text = SKLabelNode(text: text)
        text.fontName = Self.fontName
        text.fontSize = Self.fontSize
        text.verticalAlignmentMode = .center
        
        let size = CGSize(
            width:  text.frame.width  + 2.0 * Self.padding,
            height: text.frame.height + 2.0 * Self.padding
        )
        let background = SKShapeNode(rectOf: size, cornerRadius: Self.cornerRadius)
        background.fillColor = Self.fillColor
        background.lineWidth = Self.lineWidth
        addChild(background)
        
        background.addChild(text)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func display(
        forDuration duration: TimeInterval,
        completion: @escaping () -> Void = { }
    ) {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeIn(withDuration: 0.25),
            SKAction.wait(forDuration: duration),
            SKAction.fadeOut(withDuration: 0.35),
            SKAction.removeFromParent()
        ]),
            completion: completion
        )
    }
}
