// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("StatsDPacket histogram + distribution")
struct StatsDHistogramDistributionTests {
    @Test("histogram (DogStatsD)")
    func histogramPlain() throws {
        var p = StatsDPacket()
        try p.histogram("payload_size", value: 4096)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "payload_size:4096|h")
    }

    @Test("histogram with sample rate and tags")
    func histogramFull() throws {
        var p = StatsDPacket()
        try p.histogram("payload_size", value: 1024, sampleRate: 0.5, tags: ["service": "api"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "payload_size:1024|h|@0.5|#service:api")
    }

    @Test("histogram throws on Etsy dialect")
    func histogramEtsyRejected() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.histogramNotSupportedInEtsyDialect) {
            try p.histogram("payload_size", value: 1024)
        }
    }

    @Test("distribution (DogStatsD)")
    func distributionPlain() throws {
        var p = StatsDPacket()
        try p.distribution("rpc_latency", value: 0.045)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "rpc_latency:0.045|d")
    }

    @Test("distribution with tags")
    func distributionTags() throws {
        var p = StatsDPacket()
        try p.distribution("rpc_latency", value: 0.045, tags: ["region": "us-west", "az": "1a"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "rpc_latency:0.045|d|#az:1a,region:us-west")
    }

    @Test("distribution throws on Etsy dialect")
    func distributionEtsyRejected() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.distributionNotSupportedInEtsyDialect) {
            try p.distribution("rpc_latency", value: 0.045)
        }
    }
}
