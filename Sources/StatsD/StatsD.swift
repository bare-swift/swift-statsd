// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free StatsD wire-format encoder.
///
/// Pure encoder — no UDP transport. Use ``StatsDPacket`` to build a
/// datagram payload, then hand its ``Bytes`` to your transport.
public enum StatsD: Sendable {
    /// Wire-format dialect. Etsy is the original universal subset;
    /// DogStatsD adds tags, histogram, and distribution.
    public enum Dialect: Sendable, Equatable {
        case etsy
        case dogStatsD
    }
}
