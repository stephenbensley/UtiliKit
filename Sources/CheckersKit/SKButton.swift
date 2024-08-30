//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SpriteKit

// Simple button implemented in SpriteKit
public class SKButton: SKNode {
    public static let cornerRadius = 20.0
    public static let lineWidth = 4.0
    public static let fontName: String = "Helvetica"
    public static let fontSize: CGFloat = 20.0
    
    // Action invoked when the button is released.
    public var action: (() -> Void)?
    
    // Is user input enabled?
    public var enabled: Bool = true {
        didSet { alpha = enabled ? 1.0 : 0.6 }
    }

    // Used to indicate the button has been pressed, but not released.
    private var pressed: Bool = false {
        didSet { alpha = pressed ? 0.6 : 1.0 }
    }

    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { }
    }
    
    public init(_ label: String, size: CGSize) {
        super.init()
        self.zPosition = Layer.controls
        
        let shape = SKShapeNode(rectOf: size, cornerRadius: Self.cornerRadius)
        shape.lineWidth = Self.lineWidth
        addChild(shape)
        
        let text = SKLabelNode(text: label)
        text.fontName = Self.fontName
        text.fontSize = Self.fontSize
        text.verticalAlignmentMode = .center
        shape.addChild(text)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func touchDown(location: CGPoint) {
        guard enabled else { return }
        pressed = true
    }
    
    private func touchUp(location: CGPoint) {
        guard enabled else { return }
        pressed = false
        action?()
    }
    
#if os(macOS)
    public override func mouseDown(with event: NSEvent) {
        touchDown(location: event.location(in: self))
    }
    public override func mouseUp(with event: NSEvent) {
        touchUp(location: event.location(in: self))
    }
#else
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(location: t.location(in: self))}
    }    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(location: t.location(in: self))}
    }
#endif
}
