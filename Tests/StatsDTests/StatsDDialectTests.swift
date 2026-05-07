// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("StatsDPacket dialect rejection")
struct StatsDDialectTests {
    @Test("Etsy + tags on counter throws")
    func etsyCounterTags() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.tagsNotSupportedInEtsyDialect) {
            try p.counter("x", value: 1, tags: ["k": "v"])
        }
    }

    @Test("Etsy + tags on gauge throws")
    func etsyGaugeTags() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.tagsNotSupportedInEtsyDialect) {
            try p.gauge("x", value: 1.0, tags: ["k": "v"])
        }
    }

    @Test("Etsy + tags on timer throws")
    func etsyTimerTags() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.tagsNotSupportedInEtsyDialect) {
            try p.timer("x", milliseconds: 1.0, tags: ["k": "v"])
        }
    }

    @Test("Etsy + tags on set throws")
    func etsySetTags() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.tagsNotSupportedInEtsyDialect) {
            try p.set("x", member: "v", tags: ["k": "v"])
        }
    }

    @Test("Etsy + histogram throws (regardless of tags)")
    func etsyHistogram() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.histogramNotSupportedInEtsyDialect) {
            try p.histogram("x", value: 1.0)
        }
    }

    @Test("Etsy + distribution throws (regardless of tags)")
    func etsyDistribution() {
        var p = StatsDPacket(dialect: .etsy)
        #expect(throws: StatsDError.distributionNotSupportedInEtsyDialect) {
            try p.distribution("x", value: 1.0)
        }
    }

    @Test("Etsy without tags works for universal types")
    func etsyUniversalNoTags() throws {
        var p = StatsDPacket(dialect: .etsy)
        try p.counter("hits", value: 5)
        try p.gauge("temp", value: 70.0)
        try p.timer("latency", milliseconds: 100)
        try p.set("users", member: "alice")
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload.contains("hits:5|c"))
        #expect(payload.contains("temp:70|g"))
        #expect(payload.contains("latency:100|ms"))
        #expect(payload.contains("users:alice|s"))
    }
}
