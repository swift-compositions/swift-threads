# swift-threads

Use this package when you work with real threads rather than tasks. Start from `Kernel.Thread.Pool` when async code has to call blocking work, such as a blocking system call, without tying up the cooperative pool. Use `Kernel.Thread.Semaphore`, `Kernel.Thread.Gate` and `Kernel.Thread.Barrier` to coordinate threads that block, `Kernel.Thread.Worker` for one long-lived thread you stop and join, and `Kernel.Thread.Actor` for an actor that runs on a thread executor. If the code that waits is async, use `Async.Semaphore` from swift-async-semaphore instead of `Kernel.Thread.Semaphore`. For raw thread spawning use swift-kernel, and for executors use swift-executors.

## Laws

- A `Kernel.Thread.Pool` runs at most `admitted` operations at once and holds at most `queued` more waiting for a slot. Both default to 256. A request beyond both bounds fails at once with a capacity error and never waits.
- The timeout of `Kernel.Thread.Pool.run(timeout:_:)` counts from the call, so time spent waiting for admission uses up the budget.
- A queued operation whose caller times out or is cancelled never runs, and its slot is freed for the next request.
- An operation that has started is never interrupted. If its caller times out, is cancelled or is shut down, the caller resumes at once with that error, the operation runs to the end on its thread, and its result is destroyed.
- `Kernel.Thread.Pool.shutdown()` fails every waiting caller with a shutdown error, including callers whose operation is still running, and queued operations never run. It then blocks until the running operations finish. Every later `run` fails with a shutdown error.
- The throwing form of `Kernel.Thread.Pool.run(timeout:_:)` keeps the two failures apart: pool failures are the `left` side of the thrown `Either`, and the operation's own error is the `right` side.
- `Kernel.Thread.Semaphore.run` blocks the calling thread until a permit is free. With a throwing body, only semaphore failures are thrown. The body's own error comes back inside the returned `Swift.Result`.
- `Kernel.Thread.Semaphore.Run.timeout(_:)` returns nil without running the body when no permit frees up in time.
- `Kernel.Thread.Semaphore.Run.cancellable(_:)` checks the token by polling, every 10 milliseconds unless `Kernel.Thread.Semaphore.Run.Cancellable.poll(_:)` sets another interval, and never less than 1 millisecond. A token cancelled before a permit is acquired fails the run without running the body. A token cancelled while the body runs discards the body's result and the run fails as cancelled.
- When a semaphore is shut down and a waiter's token is cancelled, the waiter fails with shutdown.
- After `Kernel.Thread.Semaphore.shutdown` new runs and threads still blocked waiting fail with shutdown, while runs that hold a permit finish normally. `Kernel.Thread.Semaphore.Shutdown.wait()` shuts the semaphore down if it is still open, then blocks until no permit is held.
- `Kernel.Thread.Gate` opens once and stays open. Opening it again does nothing.
- `Kernel.Thread.Barrier` releases once, when `count` threads have arrived, and does not reset. Any arrival after that returns true at once. `Kernel.Thread.Barrier.arrive(timeout:)` waits 5 seconds by default and returns false on timeout, and a thread that timed out still counts as arrived.
- `Kernel.Thread.Worker.stop()` only sets a flag. The body has to check `Kernel.Thread.Worker.Token.shouldStop` and return by itself. Calling `Kernel.Thread.Worker.join()` from the worker's own thread traps instead of deadlocking.
