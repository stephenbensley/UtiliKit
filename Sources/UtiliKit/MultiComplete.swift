//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/UtiliKit/blob/main/LICENSE.
//

// Coalesces multiple completions into a single callback.
public class MultiComplete {
    // Number of completions that are still being waited for.
    private var pending: Int
    // Final callback to invoke.
    private var completion: (() -> Void)

    // Invokes completion after self.complete() has been invoked waitCount times.
    public init(waitCount: Int, completion: @escaping () -> Void) {
        self.pending = waitCount
        self.completion = completion
    }

    public func complete() {
        assert(pending > 0)
        pending -= 1
        guard pending == 0 else { return }
        completion()
    }
}
