//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/RGU/blob/main/LICENSE.
//

extension Array {    
    // Binary searches the array for a given element. If the array is not sorted, the behavior is
    // unspecified. If the value is found, returns the index of the matching element. If there are
    // multiple matches, then any one of the matches could be returned. If the value is not found,
    // then nil is returned.
    func bsearch(for element: Self.Element) -> Self.Index?  where Element: Comparable {
        bsearch(forKey: element, extractedBy: { $0 }, sortedBy: <)
    }
    
    // Binary searches the array using the given predicate as the comparison between elements. The
    // array must be sorted by the same predicte.
    func bsearch(
        for element: Self.Element,
        by areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool
    ) rethrows -> Self.Index? {
        try bsearch(forKey: element, extractedBy: { $0 }, sortedBy: areInIncreasingOrder)
    }
    
    // Binary searches the array with a key extraction function. The array must be sorted by the
    // key.
    func bsearch<T>(
        forKey key: T,
        extractedBy extractKey: (Self.Element) throws -> T
    ) rethrows -> Self.Index? where T: Comparable {
        try bsearch(forKey: key, extractedBy: extractKey, sortedBy: <)
    }

    // Binary searches the array with both a key extraction function and a predicate to use as
    // the comparison between keys.
    func bsearch<T>(
        forKey key: T,
        extractedBy extractKey: (Self.Element) throws -> T,
        sortedBy areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> Self.Index? {
        var lo: Self.Index = 0
        var hi: Self.Index = self.count - 1
        while lo <= hi {
            let mid: Self.Index = (lo + hi) / 2
            if try areInIncreasingOrder(extractKey(self[mid]), key) {
                lo = mid + 1
            } else if try areInIncreasingOrder(key, extractKey(self[mid])) {
                hi = mid - 1
            } else {
                return mid
            }
        }
        return nil
    }
}
