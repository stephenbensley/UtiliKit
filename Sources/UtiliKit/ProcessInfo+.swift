//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import Foundation

public extension ProcessInfo {
    // Returns the number of performance cores.
    var performanceProcessorCount: Int {
        var result: Int64 = 0;
        var size = MemoryLayout<Int64>.size
        guard sysctlbyname("hw.perflevel0.physicalcpu", &result, &size, nil, 0) == 0 else {
            // If sysctl fails, we'll assume all CPUs are performance.
            return activeProcessorCount
        }
        return Int(result)
    }
}
