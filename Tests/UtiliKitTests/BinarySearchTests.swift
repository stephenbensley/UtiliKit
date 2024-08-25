//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import XCTest
@testable import UtiliKit

final class BinarySearchTests: XCTestCase {
    func testBSearch() throws {
        let a = [1, 3, 5, 5, 7, 9]
        var match: Int?
        
        match = a.bsearch(for: 0)
        XCTAssertNil(match)
        match = a.bsearch(for: 6)
        XCTAssertNil(match)
        match = a.bsearch(for: 10)
        XCTAssertNil(match)
        
        match = a.bsearch(for: 1)
        XCTAssertNotNil(match)
        XCTAssert(a[match!] == 1)
        match = a.bsearch(for: 5)
        XCTAssertNotNil(match)
        XCTAssert(a[match!] == 5)
        match = a.bsearch(for: 9)
        XCTAssertNotNil(match)
        XCTAssert(a[match!] == 9)
    }
}
