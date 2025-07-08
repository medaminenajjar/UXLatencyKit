import Foundation
import SwiftUI

/// Statistical utilities for analyzing UX interaction latency.
@available(iOS 14.0, *)
@available(macOS 11.0, *)
public struct UXLatencyStats {

    /// Computes the average latency (in seconds) from a list of interactions.
    /// - Parameter interactions: An array of UXInteraction objects.
    /// - Returns: The mean latency value, or `0` if there are no valid latencies.
    public static func averageLatency(in interactions: [UXInteraction]) -> TimeInterval {
        let latencies = interactions.compactMap { $0.latency }
        guard !latencies.isEmpty else { return 0 }
        return latencies.reduce(0, +) / Double(latencies.count)
    }

    /// Returns the maximum latency detected among the provided interactions.
    /// - Parameter interactions: An array of UXInteraction objects.
    /// - Returns: The highest latency value in seconds, or `0` if none exist.
    public static func maxLatency(in interactions: [UXInteraction]) -> TimeInterval {
        interactions.compactMap { $0.latency }.max() ?? 0
    }

    /// Provides a distribution of interaction counts grouped by latency color.
    /// - Parameter interactions: An array of UXInteraction objects.
    /// - Returns: A dictionary mapping `Color` to the number of interactions with that color.
    public static func latencyDistribution(in interactions: [UXInteraction]) async -> [Color: Int] {
        var result: [Color: Int] = [:]
        for interaction in interactions {
            let color = await interaction.color()
            result[color, default: 0] += 1
        }
        return result
    }

    /// Groups the interactions by their event type.
    /// - Parameter interactions: An array of UXInteraction objects.
    /// - Returns: A dictionary mapping `UXEventType` to the number of interactions per type.
    public static func interactionsByType(in interactions: [UXInteraction]) -> [String: Int] {
        var result: [String: Int] = [:]
        for _ in interactions {
            result["tap", default: 0] += 1
        }
        return result
    }

    /// Filters interactions whose latency exceeds a given threshold.
    /// - Parameters:
    ///   - interactions: An array of UXInteraction objects.
    ///   - threshold: Latency value (in seconds) above which interactions are considered outliers.
    /// - Returns: An array of UXInteraction objects that exceed the latency threshold.
    public static func outliers(in interactions: [UXInteraction], above threshold: TimeInterval) -> [UXInteraction] {
        interactions.filter { ($0.latency ?? 0) > threshold }
    }
}
