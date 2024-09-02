//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import SwiftUI

public extension Color {
    init(hex: UInt32) {
        let r = Double((hex & 0xff0000) >> 16) / 255
        let g = Double((hex & 0x00ff00) >>  8) / 255
        let b = Double((hex & 0x0000ff)      ) / 255
        self.init(red: r, green: g, blue: b)
    }
}
