//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

// Player color -- for checkers there are always exactly two players.
public enum PlayerColor: Int, CaseIterable, Codable, CustomStringConvertible {
    case white
    case black
    
    // Returns the other color -- useful for switching sides.
    public var other: PlayerColor {
        switch self {
        case .white:
            return .black
        case .black:
            return .white
        }
    }
    
    // Display the color as a string.
    public var description: String {
        switch self {
        case .white:
            return "White"
        case .black:
            return "Black"
        }
    }
}

// Is the player a human or a computer?
public enum PlayerType: Int, Codable {
    case human
    case computer
}
