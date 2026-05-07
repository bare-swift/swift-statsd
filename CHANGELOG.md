# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-05-07

### Added
- `StatsDPacket` value type — Sendable, Foundation-free StatsD wire-format encoder. Builder pattern with `consuming finish() -> Bytes`.
- Both dialects: `StatsD.Dialect.etsy` (universal types, no tags) and `.dogStatsD` (default; adds tags, histogram, distribution).
- Universal metric types: `counter(_:value:sampleRate:tags:)` (Int64), `gauge(_:value:sampleRate:tags:)` (Double, set semantics), `gaugeDelta(_:delta:sampleRate:tags:)` (signed adjust), `timer(_:milliseconds:sampleRate:tags:)` (Double), `set(_:member:sampleRate:tags:)` (String).
- DogStatsD-only types: `histogram(_:value:sampleRate:tags:)` (`h`), `distribution(_:value:sampleRate:tags:)` (`d`).
- Sample rate (`|@<rate>`) optional per-metric, validated to `(0, 1]`.
- Tags (`|#k:v,k:v`) optional per-metric (DogStatsD only), sorted by key for deterministic output.
- Multi-metric packets joined by `\n` (no trailing newline) for batched UDP send.
- `StatsDError` typed error enum (`invalidMetricName`, `invalidTagKey`, `invalidTagValue`, `invalidSampleRate`, `tagsNotSupportedInEtsyDialect`, `histogramNotSupportedInEtsyDialect`, `distributionNotSupportedInEtsyDialect`).
- DocC documentation, full README example, NOTICE crediting Etsy StatsD and Datadog DogStatsD docs.

### Dependencies
- `swift-bytes 0.1.0` (https://github.com/bare-swift/swift-bytes) — for the `Bytes` output type. First inter-package dependency in the bare-swift ecosystem.

### Limitations (out of scope for v0.1)
- Service checks (`_sc|...`). Defer to v0.2.
- Events (`_e{...}:...`). Defer to v0.2.
- UDP transport. Caller wires `sendto()` / NIO / etc.
- Aggregation, batching, sampling decisions, MTU enforcement.
