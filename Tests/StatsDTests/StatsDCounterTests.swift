// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD
import Bytes

@Suite("StatsDPacket counter")
struct StatsDCounterTests {
    @Test("counter without tags or sample rate")
    func counterPlain() throws {
        var p = StatsDPacket()
        try p.counter("hits", value: 5)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "hits:5|c")
    }

    @Test("counter with negative value")
    func counterNegative() throws {
        var p = StatsDPacket()
        try p.counter("rebates", value: -3)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "rebates:-3|c")
    }

    @Test("counter with sample rate")
    func counterSampleRate() throws {
        var p = StatsDPacket()
        try p.counter("hits", value: 5, sampleRate: 0.1)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "hits:5|c|@0.1")
    }

    @Test("counter with tags (DogStatsD)")
    func counterWithTags() throws {
        var p = StatsDPacket()
        try p.counter("requests", value: 1, tags: ["method": "GET", "status": "200"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "requests:1|c|#method:GET,status:200")
    }

    @Test("counter with sample rate AND tags")
    func counterFull() throws {
        var p = StatsDPacket()
        try p.counter("requests", value: 1, sampleRate: 0.5, tags: ["env": "prod"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "requests:1|c|@0.5|#env:prod")
    }

    @Test("counter with invalid name throws")
    func invalidName() {
        var p = StatsDPacket()
        #expect(throws: StatsDError.invalidMetricName("bad:name")) {
            try p.counter("bad:name", value: 1)
        }
    }

    @Test("StatsDPacket is Sendable")
    func sendable() {
        let p = StatsDPacket()
        let _: any Sendable = p
    }
}
