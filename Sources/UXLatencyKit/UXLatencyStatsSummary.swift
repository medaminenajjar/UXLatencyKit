import SwiftUI

@available(iOS 14.0, *)
@available(macOS 11.0, *)
public struct UXLatencyStatsSummary {
    public let average: TimeInterval
    public let max: TimeInterval
    public let distribution: [Color: Int]

    public init(interactions: [UXInteraction]) async {
        self.average = UXLatencyStats.averageLatency(in: interactions)
        self.max = UXLatencyStats.maxLatency(in: interactions)
        self.distribution = await UXLatencyStats.latencyDistribution(in: interactions)
    }
}
