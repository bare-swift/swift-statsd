// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Internal pure-function namespace for StatsD wire-format validation
/// and primitive formatting.
enum Encoding {
    // MARK: - Validation

    /// Metric name: non-empty; reject `:`, `|`, `\n`, `@`, `#`.
    static func validateMetricName(_ name: String) throws(StatsDError) {
        guard !name.isEmpty else { throw .invalidMetricName(name) }
        for scalar in name.unicodeScalars {
            if scalar == ":" || scalar == "|" || scalar == "\n"
                || scalar == "@" || scalar == "#" {
                throw .invalidMetricName(name)
            }
        }
    }

    /// Tag key: non-empty; reject `,`, `:`, `|`, `\n`, `#`.
    static func validateTagKey(_ key: String) throws(StatsDError) {
        guard !key.isEmpty else { throw .invalidTagKey(key) }
        for scalar in key.unicodeScalars {
            if scalar == "," || scalar == ":" || scalar == "|"
                || scalar == "\n" || scalar == "#" {
                throw .invalidTagKey(key)
            }
        }
    }

    /// Tag value: reject `,`, `|`, `\n`, `#` (`:` is permitted).
    /// Empty value is permitted (some backends use it).
    static func validateTagValue(_ value: String) throws(StatsDError) {
        for scalar in value.unicodeScalars {
            if scalar == "," || scalar == "|" || scalar == "\n" || scalar == "#" {
                throw .invalidTagValue(value)
            }
        }
    }

    /// Sample rate: in `(0, 1]`. NaN rejected.
    static func validateSampleRate(_ rate: Double) throws(StatsDError) {
        if rate.isNaN || rate <= 0.0 || rate > 1.0 {
            throw .invalidSampleRate
        }
    }

    // MARK: - Formatting

    /// Format a Double for the StatsD wire. Integer-valued doubles get no
    /// trailing decimal (`5.0` → `"5"`); fractional values use Swift's
    /// default `String(_:)` rendering.
    static func formatDouble(_ value: Double) -> String {
        if value.isNaN { return "NaN" }
        if value == .infinity { return "+Inf" }
        if value == -.infinity { return "-Inf" }
        if value.rounded() == value
            && value >= Double(Int64.min)
            && value <= Double(Int64.max) {
            return String(Int64(value))
        }
        return String(value)
    }

    /// Format a tag dictionary as `#k1:v1,k2:v2`, sorted by key.
    /// Caller is responsible for having validated each key/value first.
    static func formatTags(_ tags: [String: String]) -> String {
        var out = "#"
        var first = true
        for key in tags.keys.sorted() {
            if !first { out.append(",") }
            first = false
            out.append(key)
            out.append(":")
            out.append(tags[key] ?? "")
        }
        return out
    }
}
