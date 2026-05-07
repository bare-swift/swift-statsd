// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD
import Bytes

@Suite("StatsDPacket gauge")
struct StatsDGaugeTests {
    @Test("gauge sets value (no leading sign)")
    func gaugeSet() throws {
        var p = StatsDPacket()
        try p.gauge("temp", value: 72.5)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "temp:72.5|g")
    }

    @Test("gauge with integer-valued Double drops .0")
    func gaugeInteger() throws {
        var p = StatsDPacket()
        try p.gauge("queue_depth", value: 100.0)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "queue_depth:100|g")
    }

    @Test("gauge with tags (DogStatsD)")
    func gaugeWithTags() throws {
        var p = StatsDPacket()
        try p.gauge("temp", value: 72.5, tags: ["room": "kitchen"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "temp:72.5|g|#room:kitchen")
    }

    @Test("gaugeDelta with positive delta uses leading '+'")
    func gaugeDeltaPositive() throws {
        var p = StatsDPacket()
        try p.gaugeDelta("active_conns", delta: 5)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "active_conns:+5|g")
    }

    @Test("gaugeDelta with negative delta uses leading '-'")
    func gaugeDeltaNegative() throws {
        var p = StatsDPacket()
        try p.gaugeDelta("active_conns", delta: -3)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "active_conns:-3|g")
    }

    @Test("gaugeDelta with zero uses leading '+'")
    func gaugeDeltaZero() throws {
        var p = StatsDPacket()
        try p.gaugeDelta("active_conns", delta: 0)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "active_conns:+0|g")
    }

    @Test("gaugeDelta with fractional delta")
    func gaugeDeltaFractional() throws {
        var p = StatsDPacket()
        try p.gaugeDelta("temp", delta: -0.5)
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "temp:-0.5|g")
    }
}
