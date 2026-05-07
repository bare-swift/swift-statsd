// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("StatsDPacket set")
struct StatsDSetTests {
    @Test("set with string member")
    func setMember() throws {
        var p = StatsDPacket()
        try p.set("unique_users", member: "alice")
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "unique_users:alice|s")
    }

    @Test("set with numeric-string member")
    func setNumericMember() throws {
        var p = StatsDPacket()
        try p.set("user_ids", member: "12345")
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "user_ids:12345|s")
    }

    @Test("set with tags (DogStatsD)")
    func setTags() throws {
        var p = StatsDPacket()
        try p.set("session_ids", member: "abc123", tags: ["region": "us-east"])
        let payload = String(decoding: p.finish().storage, as: UTF8.self)
        #expect(payload == "session_ids:abc123|s|#region:us-east")
    }
}
