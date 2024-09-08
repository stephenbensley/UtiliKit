//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/CheckersKit/blob/main/LICENSE.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias SKColor = NSColor
#else
import UIKit
public typealias SKColor = UIColor
#endif

// Common colors used across CheckersKit.

public extension Color {
    static let background      = Color(hex: 0x699DB5)
    static let bottomSheet     = Color.gray
    static let gameBoardFill   = Color(hex: 0xE7CB7E)
    static let gameBoardStroke = Color(hex: 0x4E3524)
    static let selected        = Color(hex: 0x04D9FF)
    static let threatened      = Color(hex: 0xFF4545)
}

public extension SKColor {
    static let background      = SKColor(Color.background)
    static let bottomSheet     = SKColor(Color.bottomSheet)
    static let gameBoardFill   = SKColor(Color.gameBoardFill)
    static let gameBoardStroke = SKColor(Color.gameBoardStroke)
    static let selected        = SKColor(Color.selected)
    static let threatened      = SKColor(Color.threatened)
}
