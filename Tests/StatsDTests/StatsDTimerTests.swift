// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("StatsDPacket timer")
struct StatsDTimerTests {
    @Test("timer with integer-valued ms")
    func timerInteger() throws {
        var p = StatsDPacket()
        try p.timer("req_latency", milliseconds: 123)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "req_latency:123|ms")
    }

    @Test("timer with fractional ms")
    func timerFractional() throws {
        var p = StatsDPacket()
        try p.timer("req_latency", milliseconds: 12.34)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "req_latency:12.34|ms")
    }

    @Test("timer with sample rate")
    func timerSampleRate() throws {
        var p = StatsDPacket()
        try p.timer("req_latency", milliseconds: 200, sampleRate: 0.1)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "req_latency:200|ms|@0.1")
    }

    @Test("timer with tags (DogStatsD)")
    func timerTags() throws {
        var p = StatsDPacket()
        try p.timer("req_latency", milliseconds: 50, tags: ["route": "/api"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "req_latency:50|ms|#route:/api")
    }
}
