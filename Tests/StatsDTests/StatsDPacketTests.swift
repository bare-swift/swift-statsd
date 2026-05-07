// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("StatsDPacket multi-metric + ordering")
struct StatsDPacketTests {
    @Test("empty packet finishes to empty Bytes")
    func emptyPacket() {
        var p = StatsDPacket()
        let payload = p.finish()
        #expect(payload.isEmpty)
    }

    @Test("multiple metrics joined by '\\n', no trailing newline")
    func multiMetric() throws {
        var p = StatsDPacket()
        try p.counter("hits", value: 1)
        try p.gauge("temp", value: 70)
        try p.timer("latency", milliseconds: 100)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "hits:1|c\ntemp:70|g\nlatency:100|ms")
        #expect(!payload.hasSuffix("\n"))
    }

    @Test("tag ordering is deterministic regardless of insertion order")
    func tagOrdering() throws {
        var p1 = StatsDPacket()
        try p1.counter("x", value: 1, tags: ["zebra": "z", "apple": "a", "mango": "m"])
        let payload1 = String(decoding: p1.finish().storage, as: UTF8.self)

        var p2 = StatsDPacket()
        try p2.counter("x", value: 1, tags: ["mango": "m", "apple": "a", "zebra": "z"])
        let payload2 = String(decoding: p2.finish().storage, as: UTF8.self)

        #expect(payload1 == payload2)
        #expect(payload1 == "x:1|c|#apple:a,mango:m,zebra:z")
    }

    @Test("invalid sample rate throws")
    func invalidSampleRate() {
        var p = StatsDPacket()
        #expect(throws: StatsDError.invalidSampleRate) {
            try p.counter("x", value: 1, sampleRate: 0)
        }
        #expect(throws: StatsDError.invalidSampleRate) {
            try p.counter("x", value: 1, sampleRate: 1.5)
        }
        #expect(throws: StatsDError.invalidSampleRate) {
            try p.counter("x", value: 1, sampleRate: -0.1)
        }
    }

    @Test("invalid tag key throws")
    func invalidTagKey() {
        var p = StatsDPacket()
        #expect(throws: StatsDError.invalidTagKey("bad,key")) {
            try p.counter("x", value: 1, tags: ["bad,key": "v"])
        }
    }

    @Test("invalid tag value throws")
    func invalidTagValue() {
        var p = StatsDPacket()
        #expect(throws: StatsDError.invalidTagValue("bad|val")) {
            try p.counter("x", value: 1, tags: ["k": "bad|val"])
        }
    }
}
