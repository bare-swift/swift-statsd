// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import StatsD

@Suite("StatsDError")
struct StatsDErrorTests {
    @Test("StatsDError is Sendable, Equatable, Error")
    func conformances() {
        let a: StatsDError = .invalidMetricName("foo")
        let b: StatsDError = .invalidMetricName("foo")
        let c: StatsDError = .invalidMetricName("bar")
        let d: StatsDError = .invalidSampleRate
        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
        let _: any Error = a
        let _: any Sendable = a
    }

    @Test("All seven cases are distinguishable")
    func cases() {
        let xs: [StatsDError] = [
            .invalidMetricName("x"),
            .invalidTagKey("x"),
            .invalidTagValue("x"),
            .invalidSampleRate,
            .tagsNotSupportedInEtsyDialect,
            .histogramNotSupportedInEtsyDialect,
            .distributionNotSupportedInEtsyDialect,
        ]
        for i in 0..<xs.count {
            for j in 0..<xs.count where i != j {
                #expect(xs[i] != xs[j])
            }
        }
    }
}
