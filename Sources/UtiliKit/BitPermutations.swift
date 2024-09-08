//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

// Generates all possible permutations of a bit set.
public class BitPermutations {
    
    // Return all possible permutations of the specified bits.
    public static func all(bitCount: Int, nonZeroCount: Int) -> [Int] {
        var result = [Int]()
        
        // Array of Bools indicating which bits are set
        var selectors = [Bool](repeating: false, count: bitCount)
        // Start with the low order bits set
        for i in 0..<nonZeroCount { selectors[i] = true }
         
        repeat {
            // Convert the selectors to bits and add to result
            result.append((0..<bitCount).filter({ selectors[$0] }).reduce(0) { $0 | 1 << $1 })
            // Cycle through the permutations
        } while nextPermutation(&selectors)
        
        return result
    }
    
    private static func nextPermutation(_ selectors: inout [Bool]) -> Bool {
        // Counts of 0 and 1 only have one permutation, and the loop below can't handle these
        // cases.
        guard selectors.count > 1 else {
            return false
        }
        
        // Find first selector that's set where following selector isn't set.
        for i in 0..<selectors.count - 1 where selectors[i] && !selectors[i+1] {
            // Find first selector that's set. Guaranteed to succeed since count > 0
            let j = selectors.firstIndex(of: true)!
            // Swap these ...
            selectors.swapAt(i + 1, j)
            // ... and reverse all the preceding elements.
            selectors[0...i].reverse()
            return true
        }
        
        // All the true selectors have been pushed to the end of the array, so we're done.
        return false
    }
}
