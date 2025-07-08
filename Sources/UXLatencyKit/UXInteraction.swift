import Foundation
import SwiftUI

/// Represents a measurable user interaction event.
/// Includes timestamps for when the interaction starts and when the visual feedback occurs.
public struct UXInteraction: Identifiable, Sendable {
    /// Unique identifier for the interaction.
    public let id: String

    /// Timestamp for when the interaction started (e.g. when user tapped).
    public let start: Date

    /// Timestamp for when the UI reacted (e.g. appeared or updated).
    public var feedback: Date?

    /// The latency between start and feedback, in seconds.
    public var latency: TimeInterval? {
        guard let feedback else { return nil }
        return feedback.timeIntervalSince(start)
    }
}

@available(iOS 14.0, *)
@available(macOS 11.0, *)
public extension UXInteraction {
    func color(using tracker: UXLatencyTracker = .shared) async -> Color {
        await tracker.thresholds.color(for: latency)
    }
}
