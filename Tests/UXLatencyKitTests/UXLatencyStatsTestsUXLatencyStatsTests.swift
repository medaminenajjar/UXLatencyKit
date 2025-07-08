import Testing
@testable import UXLatencyKit

struct UXLatencyStatsTestsUXLatencyStatsTests {
    
    /// Test case for verifying average latency calculation.
    @Test("averageLatency returns correct value")
    func testAverageLatency() {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let interactions = [
            UXInteraction(id: "btn1", start: .init(timeIntervalSince1970: 0), feedback: .init(timeIntervalSince1970: 0.2)),
            UXInteraction(id: "btn2", start: .init(timeIntervalSince1970: 1), feedback: .init(timeIntervalSince1970: 1.4))
        ]
        let result = UXLatencyStats.averageLatency(in: interactions)
        // Expected average: (0.2 + 0.4) / 2 = 0.3
        #expect(String(format: "%.3f", result) == "0.300")
    }
    
    /// Test case for verifying max latency detection.
    @Test("maxLatency returns highest latency")
    func testMaxLatency() {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let interactions = [
            UXInteraction(id: "slow", start: .init(timeIntervalSince1970: 0), feedback: .init(timeIntervalSince1970: 0.8)),
            UXInteraction(id: "fast", start: .init(timeIntervalSince1970: 1), feedback: .init(timeIntervalSince1970: 1.2))
        ]
        let result = UXLatencyStats.maxLatency(in: interactions)
        // Highest latency should be 0.8
        #expect(String(format: "%.1f", result) == "0.8")
    }
    
    /// Test case for verifying latency color distribution logic.
    @Test("latencyDistribution returns correct color grouping")
    func testLatencyDistribution() async {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let interactions = [
            // Green (latency < 0.4)
            UXInteraction(id: "green", start: .init(timeIntervalSince1970: 0), feedback: .init(timeIntervalSince1970: 0.3)),
            // Orange (latency < 0.9)
            UXInteraction(id: "orange", start: .init(timeIntervalSince1970: 1), feedback: .init(timeIntervalSince1970: 1.6)),
            // Red (latency >= 0.9)
            UXInteraction(id: "red", start: .init(timeIntervalSince1970: 2), feedback: .init(timeIntervalSince1970: 3.1))
        ]
        let result = await UXLatencyStats.latencyDistribution(in: interactions)
        // Each latency category should have one count
        #expect(result[.green] == 1)
        #expect(result[.orange] == 1)
        #expect(result[.red] == 1)
    }
    
    /// Test case for verifying counts grouped by UXEventType.
    @Test("interactionsByType returns correct counts")
    func testInteractionsByType() {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let interactions = [
            UXInteraction(id: "a", start: .init(), feedback: .init()),
            UXInteraction(id: "b", start: .init(), feedback: .init()),
            UXInteraction(id: "c", start: .init(), feedback: .init())
        ]
        let result = UXLatencyStats.interactionsByType(in: interactions)
        #expect(result["tap"] == 3)
    }
    
    /// Test case for identifying slow interactions above latency threshold.
    @Test("outliers returns interactions above threshold")
    func testOutliers() {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let interactions = [
            UXInteraction(id: "fast", start: .init(timeIntervalSince1970: 0), feedback: .init(timeIntervalSince1970: 0.2)),
            UXInteraction(id: "slow", start: .init(timeIntervalSince1970: 1), feedback: .init(timeIntervalSince1970: 2.5))
        ]
        let result = UXLatencyStats.outliers(in: interactions, above: 1.0)
        // Only the slow interaction exceeds the threshold
        #expect(result.count == 1)
        #expect(result.first?.id == "slow")
    }
}
