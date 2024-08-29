//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SwiftUI
import SpriteKit

// Creates a SpriteView with the maximum size possible.
public struct AutoSizedSpriteView: View {
    private var scene: SKScene
    
    public init(scene: SKScene) {
        self.scene = scene
    }
    
    public var body: some View {
        GeometryReader { geo in
            SpriteView(scene: resizeScene(size: geo.size))
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func resizeScene(size: CGSize) -> SKScene {
        scene.size = size
        return scene
    }
}
