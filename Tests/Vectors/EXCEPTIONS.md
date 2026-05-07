# Test-parity exceptions

Per [RFC-0002](https://github.com/bare-swift/bare-swift/blob/main/rfcs/0002-test-parity-policy.md) and its 2026-05-07 amendment per [RFC-0004](https://github.com/bare-swift/bare-swift/blob/main/rfcs/0004-inline-test-vectors.md), this file documents how `swift-statsd` validates correctness.

## Source: StatsD spec (Etsy) + DogStatsD docs (Datadog)

There is no upstream Rust crate to track parity against. The wire format
is the source of truth, documented at:

- https://github.com/statsd/statsd/blob/master/docs/metric_types.md
- https://docs.datadoghq.com/developers/dogstatsd/datagram_shell/

The Swift translation:

- `EncodingTests.swift` covers per-rule validation (metric name, tag key,
  tag value, sample rate, double formatting).
- `StatsDCounterTests.swift` / `StatsDGaugeTests.swift` /
  `StatsDTimerTests.swift` / `StatsDSetTests.swift` /
  `StatsDHistogramDistributionTests.swift` cover per-metric-type
  canonical wire-format examples.
- `StatsDPacketTests.swift` covers multi-metric packet assembly,
  sample-rate encoding, and tag-ordering determinism.
- `StatsDDialectTests.swift` covers cross-cutting dialect rejection
  paths (tags-on-Etsy, histogram-on-Etsy, distribution-on-Etsy).

## Out of scope for v0.1 (no Swift counterpart)

- Service checks (`_sc|<name>|<status>|...`) — DogStatsD only. Defer to v0.2.
- Events (`_e{<title-len>,<text-len>}:<title>|<text>|...`) — DogStatsD only.
  Multi-line, character-counted format. Defer to v0.2.
- UDP transport. Caller wires `sendto()` / NIO / etc. v0.1 is encoder-only.
- Aggregation, batching, sampling decisions, MTU enforcement. Caller policy.

## Refresh

When the StatsD spec or DogStatsD docs change (rare), re-read and add
Swift-side tests for any new cases. Record source pin here when refreshing:

- StatsD spec: tracked at upstream commit (record at next refresh)
- DogStatsD docs: tracked at upstream version (record at next refresh)
