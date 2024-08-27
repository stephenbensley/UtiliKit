//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SwiftUI

#if os(macOS)
import AppKit
public typealias BoardGameColor = NSColor
#else
import UIKit
public typealias BoardGameColor = UIColor
#endif

public struct GamePalette {
    public static let background = BoardGameColor(Color("background"))
    public static let selected = BoardGameColor(Color("selected"))
    public static let threatened = BoardGameColor(Color("threatened"))
}
