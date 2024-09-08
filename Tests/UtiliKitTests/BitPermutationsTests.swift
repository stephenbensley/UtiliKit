//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import XCTest
@testable import UtiliKit

final class BitPermutationsTests: XCTestCase {
    func testAll() throws {
        let bitCount = 8
        let nonZeroCount = 3
        
        // Generate them the brute force way.
        let expected = (0..<(1 << bitCount)).filter( { $0.nonzeroBitCount == nonZeroCount} )
        // Generate using our implementation.
        let actual = BitPermutations.all(bitCount: bitCount, nonZeroCount: nonZeroCount)
        
        XCTAssert(expected.sorted() == actual.sorted())
    }
}
