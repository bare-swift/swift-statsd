# ``StatsD``

Sendable, Foundation-free StatsD wire-format encoder for Swift 6.

## Overview

`swift-statsd` produces ready-to-send UDP datagram bodies in the StatsD
text protocol. Pure encoder — no UDP transport, no aggregation. Caller
wires `sendto()` (POSIX), NIO datagram channel, or whatever transport
they already use.

Two dialects:

- **Etsy** (original) — universal metric types (counter, gauge, timer, set), no tags.
- **DogStatsD** — adds tags, histogram, distribution.

```swift
import StatsD

var packet = StatsDPacket()    // dialect: .dogStatsD by default
try packet.counter("requests", value: 1, tags: ["status": "200"])
try packet.timer("latency", milliseconds: 42.0)
let payload = packet.finish()  // Bytes ready for UDP send
```

## Topics

### Packet

- ``StatsDPacket``
- ``StatsD/Dialect``

### Universal metric types

- ``StatsDPacket/counter(_:value:sampleRate:tags:)``
- ``StatsDPacket/gauge(_:value:sampleRate:tags:)``
- ``StatsDPacket/gaugeDelta(_:delta:sampleRate:tags:)``
- ``StatsDPacket/timer(_:milliseconds:sampleRate:tags:)``
- ``StatsDPacket/set(_:member:sampleRate:tags:)``

### DogStatsD-only

- ``StatsDPacket/histogram(_:value:sampleRate:tags:)``
- ``StatsDPacket/distribution(_:value:sampleRate:tags:)``

### Errors

- ``StatsDError``
