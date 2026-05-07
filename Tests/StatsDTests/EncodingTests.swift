// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("Encoding")
struct EncodingTests {
    // MARK: - Metric name

    @Test("validateMetricName accepts canonical names")
    func validNames() throws {
        for name in ["http_requests", "user.signup.count", "_x", "Aa-Zz_0-9"] {
            try Encoding.validateMetricName(name)
        }
    }

    @Test("validateMetricName rejects empty / forbidden chars")
    func invalidNames() {
        let bad = ["", "has:colon", "has|pipe", "has\nnewline", "has@at", "has#hash"]
        for name in bad {
            #expect(throws: StatsDError.invalidMetricName(name)) {
                try Encoding.validateMetricName(name)
            }
        }
    }

    // MARK: - Tag key

    @Test("validateTagKey accepts canonical keys")
    func validTagKeys() throws {
        for key in ["method", "status_code", "_x"] {
            try Encoding.validateTagKey(key)
        }
    }

    @Test("validateTagKey rejects empty / forbidden chars")
    func invalidTagKeys() {
        let bad = ["", "has,comma", "has:colon", "has|pipe", "has\nnewline", "has#hash"]
        for key in bad {
            #expect(throws: StatsDError.invalidTagKey(key)) {
                try Encoding.validateTagKey(key)
            }
        }
    }

    // MARK: - Tag value

    @Test("validateTagValue accepts canonical values, including ':'")
    func validTagValues() throws {
        for value in ["GET", "200", "us-west-2", "v1:beta", ""] {
            try Encoding.validateTagValue(value)
        }
    }

    @Test("validateTagValue rejects forbidden chars (`,`, `|`, `\\n`, `#`)")
    func invalidTagValues() {
        let bad = ["has,comma", "has|pipe", "has\nnewline", "has#hash"]
        for value in bad {
            #expect(throws: StatsDError.invalidTagValue(value)) {
                try Encoding.validateTagValue(value)
            }
        }
    }

    // MARK: - Sample rate

    @Test("validateSampleRate accepts (0, 1]")
    func validSampleRates() throws {
        for r in [0.001, 0.1, 0.5, 1.0] {
            try Encoding.validateSampleRate(r)
        }
    }

    @Test("validateSampleRate rejects 0, negative, > 1, NaN")
    func invalidSampleRates() {
        let bad: [Double] = [0.0, -0.1, 1.5, .nan]
        for r in bad {
            #expect(throws: StatsDError.invalidSampleRate) {
                try Encoding.validateSampleRate(r)
            }
        }
    }

    // MARK: - Double formatting

    @Test("formatDouble emits integer-valued doubles without trailing .0")
    func formatDoubleInteger() {
        #expect(Encoding.formatDouble(5.0) == "5")
        #expect(Encoding.formatDouble(0.0) == "0")
        #expect(Encoding.formatDouble(-3.0) == "-3")
        #expect(Encoding.formatDouble(1000000.0) == "1000000")
    }

    @Test("formatDouble emits fractional doubles with decimal point")
    func formatDoubleFractional() {
        #expect(Encoding.formatDouble(5.5) == "5.5")
        #expect(Encoding.formatDouble(-1.25) == "-1.25")
        #expect(Encoding.formatDouble(0.001) == "0.001")
    }

    @Test("formatDouble emits +Inf / -Inf / NaN literally")
    func formatDoubleSpecial() {
        #expect(Encoding.formatDouble(.infinity) == "+Inf")
        #expect(Encoding.formatDouble(-.infinity) == "-Inf")
        #expect(Encoding.formatDouble(.nan) == "NaN")
    }

    // MARK: - Tag formatting

    @Test("formatTags sorts keys lexicographically and produces #k:v,k:v")
    func formatTagsSorted() {
        let result = Encoding.formatTags(["region": "us-west", "az": "1a"])
        #expect(result == "#az:1a,region:us-west")
    }

    @Test("formatTags single tag")
    func formatTagsSingle() {
        let result = Encoding.formatTags(["env": "prod"])
        #expect(result == "#env:prod")
    }
}
