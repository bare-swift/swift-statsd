// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes

/// Sendable, value-typed StatsD packet builder. Per-metric methods append
/// `\n`-separated lines into an internal `Bytes` buffer; ``finish()``
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

    /// Gauge (`g`). Sets the running gauge to `value`.
    public mutating func gauge(
        _ name: String, value: Double,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        try appendLine(
            name: name,
            valueString: Encoding.formatDouble(value),
            type: "g",
            sampleRate: sampleRate,
            tags: tags
        )
    }

    /// Gauge delta (`+5|g` / `-5|g`). Adjusts the running gauge by `delta`.
    /// To *set* the gauge, use ``gauge(_:value:sampleRate:tags:)``.
    public mutating func gaugeDelta(
        _ name: String, delta: Double,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        let formatted: String = Encoding.formatDouble(delta)
        let signed: String
        if delta < 0 || formatted.hasPrefix("-") {
            signed = formatted
        } else {
            signed = "+" + formatted
        }
        try appendLine(
            name: name,
            valueString: signed,
            type: "g",
            sampleRate: sampleRate,
            tags: tags
        )
    }

    /// Timer (`ms`). Records a duration in milliseconds.
    public mutating func timer(
        _ name: String, milliseconds: Double,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        try appendLine(
            name: name,
            valueString: Encoding.formatDouble(milliseconds),
            type: "ms",
            sampleRate: sampleRate,
            tags: tags
        )
    }

    /// Set (`s`). Records an addition to a set of unique values; the
    /// receiving aggregator computes set cardinality.
    public mutating func set(
        _ name: String, member: String,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        try appendLine(
            name: name,
            valueString: member,
            type: "s",
            sampleRate: sampleRate,
            tags: tags
        )
    }

    /// Histogram (`h`) — DogStatsD only. Throws ``StatsDError/histogramNotSupportedInEtsyDialect``
    /// when `dialect == .etsy`.
    public mutating func histogram(
        _ name: String, value: Double,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        if dialect == .etsy {
            throw .histogramNotSupportedInEtsyDialect
        }
        try appendLine(
            name: name,
            valueString: Encoding.formatDouble(value),
            type: "h",
            sampleRate: sampleRate,
            tags: tags
        )
    }

    /// Distribution (`d`) — DogStatsD only. Throws ``StatsDError/distributionNotSupportedInEtsyDialect``
    /// when `dialect == .etsy`.
    public mutating func distribution(
        _ name: String, value: Double,
        sampleRate: Double? = nil,
        tags: [String: String] = [:]
    ) throws(StatsDError) {
        if dialect == .etsy {
            throw .distributionNotSupportedInEtsyDialect
        }
        try appendLine(
            name: name,
            valueString: Encoding.formatDouble(value),
            type: "d",
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
