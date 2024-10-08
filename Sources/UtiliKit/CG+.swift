//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import CoreGraphics

// Assorted useful extensions to CoreGraphics types

infix operator ~=: ComparisonPrecedence

public extension CGPoint {
    // Test for approximate equality. Returns true if the points are within 1/2 a pixel.
    static func ~= (lhs: CGPoint, rhs: CGPoint) -> Bool {
        (abs(lhs.x - rhs.x) < 0.5) && (abs(lhs.y - rhs.y) < 0.5)
    }
    
    var reflectedOverX: Self { .init(x: +x, y: -y) }
    var reflectedOverY: Self { .init(x: -x, y: +y) }
}

public extension CGSize {
    var aspectRatio: CGFloat { width/height }
    
    func scaled(by scaleFactor: CGFloat) -> CGSize {
        .init(width: width * scaleFactor, height: height * scaleFactor)
    }
    
    func shrinkToAspectRatio(_ aspectRatio: CGFloat) -> Self {
        var result = self
        if aspectRatio > self.aspectRatio {
            // Desired AR is wider, so shrink the height.
            result.height = result.width / aspectRatio
        } else {
            // Desired AR is narrower, so shrink the width.
            result.width = result.height * aspectRatio
        }
        return result
    }
    
    func stretchToAspectRatio(_ aspectRatio: CGFloat) -> Self {
        var result = self
        if aspectRatio > self.aspectRatio {
            // Desired AR is wider, so stretch the width.
            result.width = result.height * aspectRatio
        } else {
            // Desired AR is narrower, so stretch the height.
            result.height = result.width / aspectRatio
        }
        return result
    }
}

public extension Collection<CGPoint> {
    var reflectedOverX: [CGPoint] { map { $0.reflectedOverX } }
    var reflectedOverY: [CGPoint] { map { $0.reflectedOverY } }
}
