// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Errors thrown by ``StatsDPacket`` per-metric methods.
public enum StatsDError: Error, Equatable, Sendable {
    /// Empty name, or name contains `:`, `|`, `\n`, `@`, or `#`.
    case invalidMetricName(String)

    /// Empty tag key, or key contains `,`, `:`, `|`, `\n`, or `#`.
    case invalidTagKey(String)

    /// Tag value contains `,`, `|`, `\n`, or `#`. (`:` is allowed in values.)
    case invalidTagValue(String)

    /// Sample rate is ≤ 0 or > 1.
    case invalidSampleRate

    /// `tags` is non-empty when `dialect == .etsy`.
    case tagsNotSupportedInEtsyDialect

    /// `histogram(_:)` was called with `dialect == .etsy`.
    case histogramNotSupportedInEtsyDialect

    /// `distribution(_:)` was called with `dialect == .etsy`.
    case distributionNotSupportedInEtsyDialect
}
