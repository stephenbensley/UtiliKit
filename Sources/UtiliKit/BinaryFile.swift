//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

import Foundation

// Low-level raw binary file I/O -- just a type-safe wrapper around fread/fwrite.
public class BinaryFile {
    private let stream: UnsafeMutablePointer<FILE>
    
    public init?(forReadingAtPath filePath: String) {
        guard let stream = fopen(filePath, "r") else {
            return nil
        }
        self.stream = stream
    }
    
    public init?(forWritingAtPath filePath: String) {
        guard let stream = fopen(filePath, "w+") else {
            return nil
        }
        self.stream = stream
    }
    
    deinit { fclose(stream) }
    
    public var fileSize: Int {
        let current = offset()
        let count = seekToEnd()
        seek(toOffset: current)
        return count
    }
    
    public func offset() -> Int { ftell(stream) }
    
    public func seekToEnd() -> Int {
        fseek(stream, 0, SEEK_END)
        return offset()
    }
    
    public func seek(toOffset offset: Int) {
        fseek(stream, offset, SEEK_SET)
    }
    
    public func read<T>(into data: inout T) -> Bool {
        assert(_isPOD(T.self))
        let size = MemoryLayout<T>.size
        let numRead = withUnsafeMutablePointer(to: &data) { ptr  in
            fread(ptr, size, 1, stream)
        }
        return numRead == 1
    }
    
    public func read<T>(into data: inout [T]) -> Bool {
        assert(_isPOD(T.self))
        let size = MemoryLayout<T>.size
        let numRead = data.withUnsafeMutableBufferPointer { ptr  in
            fread(ptr.baseAddress, size, ptr.count, stream)
        }
        return numRead == data.count
    }

    public func write<T>(contentsOf data: borrowing T) -> Bool {
        assert(_isPOD(T.self))
        let size = MemoryLayout<T>.size
        let numWritten = withUnsafePointer(to: data) { ptr in
            fwrite(ptr, size, 1, stream)
        }
        return numWritten == 1
    }

    public func write<T>(contentsOf data: borrowing [T]) -> Bool {
        assert(_isPOD(T.self))
        let size = MemoryLayout<T>.size
        let numWritten = data.withUnsafeBufferPointer { ptr in
            fwrite(ptr.baseAddress, size, ptr.count, stream)
        }
        return numWritten == data.count
    }
}
