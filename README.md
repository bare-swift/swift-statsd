# swift-statsd

Sendable, Foundation-free [StatsD](https://github.com/statsd/statsd) wire-format encoder for Swift 6. Supports both the original Etsy dialect and Datadog's [DogStatsD](https://docs.datadoghq.com/developers/dogstatsd/) extension (tags, histogram, distribution).

Pure encoder — no UDP transport. Output is [`Bytes`](https://github.com/bare-swift/swift-bytes) ready to hand to `sendto()` / `swift-nio` / your transport of choice.

Part of the [bare-swift](https://github.com/bare-swift) ecosystem.

## Install

```swift
.package(url: "https://github.com/bare-swift/swift-statsd.git", from: "0.1.0")
```

```swift
.product(name: "StatsD", package: "swift-statsd")
```

## Usage

```swift
import StatsD
import Bytes

// DogStatsD (default) — tags, histogram, distribution available.
var packet = StatsDPacket()
try packet.counter("http_requests", value: 1, tags: ["method": "GET", "status": "200"])
try packet.timer("request_duration", milliseconds: 123.4, tags: ["route": "/api/v1/users"])
try packet.histogram("payload_size", value: 4096)

let payload: Bytes = packet.finish()
// payload is the UDP datagram body, multiple metrics joined by '\n'.
// You hand this to your UDP send.
```

```swift
// Etsy dialect — universal types only, no tags.
var packet = StatsDPacket(dialect: .etsy)
try packet.counter("hits", value: 5)
try packet.gauge("temp", value: 72.5)
let payload = packet.finish()
```

### When to use this vs swift-prometheus

- **swift-statsd:** the aggregator (statsd-exporter, Datadog Agent, etc.) lives elsewhere; you push UDP datagrams to it.
- **swift-prometheus:** your service exposes its own `/metrics` for a Prometheus scraper to pull.

Both ship in bare-swift's observability tier.

## Documentation

Full DocC documentation: <https://bare-swift.github.io/swift-statsd/>

## License

Apache 2.0 with LLVM exception. See [LICENSE](./LICENSE) and [NOTICE](./NOTICE).
