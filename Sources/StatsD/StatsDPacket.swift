// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes

/// Sendable, value-typed StatsD packet builder. Per-metric methods append
/// `\n`-separated lines into an internal ``Bytes`` buffer; ``finish()``
/// is `consuming` and returns the UDP datagram payload.
public struct StatsDPacket: Sendable {
    public let dialect: StatsD.Dialect
    private var bytes: Bytes

    public init(dialect: StatsD.Dialect = .dogStatsD) {
        self.dialect = dialect
        self.bytes = Bytes(reservingCapacity: 256)
    }

    /// Counter (`c`). Integer-valued increment.
    public mutating func counter(
        _ name: String, value: Int64,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        try appendLine(
            name: name,
            valueString: String(value),
            type: "c",
            sampleRate: sampleRate,
            tags: tags
        )
    }

    /// Append a single metric line. Validates name, sample rate, dialect/tag
    /// compatibility, and individual tag entries.
    private mutating func appendLine(
        name: String,
        valueString: String,
        type: String,
        sampleRate: Double?,
        tags: [String: String]
    ) throws(StatsDError) {
        try Encoding.validateMetricName(name)
        if !tags.isEmpty {
            if dialect == .etsy {
                throw .tagsNotSupportedInEtsyDialect
            }
            for (k, v) in tags {
                try Encoding.validateTagKey(k)
                try Encoding.validateTagValue(v)
            }
        }
        if let r = sampleRate {
            try Encoding.validateSampleRate(r)
        }

        if !bytes.isEmpty {
            bytes.append(0x0A)   // '\n'
        }
        bytes.append(contentsOf: name.utf8)
        bytes.append(0x3A)       // ':'
        bytes.append(contentsOf: valueString.utf8)
        bytes.append(0x7C)       // '|'
        bytes.append(contentsOf: type.utf8)
        if let r = sampleRate {
            bytes.append(0x7C)
            bytes.append(0x40)   // '@'
            bytes.append(contentsOf: Encoding.formatDouble(r).utf8)
        }
        if !tags.isEmpty {
            bytes.append(0x7C)
            bytes.append(contentsOf: Encoding.formatTags(tags).utf8)
        }
    }

    /// Consume the packet and return the encoded UDP datagram payload.
    /// Multiple metrics are joined with `\n` (no trailing newline).
    public consuming func finish() -> Bytes {
        bytes
    }
}
