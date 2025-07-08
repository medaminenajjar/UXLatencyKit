import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, *)
@available(macOS 11.0, *)
/// Swift actor responsible for recording, managing, and querying latency data for user interactions.
/// Thread-safe by design via Swift Concurrency.
public actor UXLatencyTracker {
    /// Global singleton instance.
    public static let shared = UXLatencyTracker()
    
    public var thresholds = UXLatencyThresholds()

    public var statistics: UXLatencyStatsSummary {
        get async {
            await UXLatencyStatsSummary(interactions: interactions)
        }
    }
    
    init() {}
    
    /// Internal storage of recorded interactions.
    private var interactions: [UXInteraction] = []
    
    public func setup(greenLimit: TimeInterval = 0.4, orangeLimit: TimeInterval = 0.9, colorForNil: Color = .gray) {
        thresholds.greenLimit = greenLimit
        thresholds.orangeLimit = orangeLimit
        thresholds.colorForNil = colorForNil
    }
    
    /// Records the start time of a user interaction.
    /// - Parameters:
    ///   - id: Unique identifier for the interaction.
    ///   - type: Type of interaction (e.g. .tap, .scroll).
    public func recordStart(id: String) async {
        if interactions.contains(where: { $0.id == id && $0.feedback == nil }) {
            await UXLatencyLogger.log("⚠️ Interaction ID '\(id)' is already active. You may be overwriting an existing interaction.", level: .warning)
        }
        
        let start = Date()
        let interaction = UXInteraction(id: id, start: start, feedback: nil)
        interactions.removeAll(where: { $0.id == id }) // remove old if any
        interactions.append(interaction)
        
        await UXLatencyLogger.interactionStarted(id: id)
    }
    
    /// Records the feedback time for a previously started interaction.
    /// - Parameter id: Unique identifier for the interaction.
    public func recordFeedback(id: String) async {
        guard let index = interactions.lastIndex(where: { $0.id == id && $0.feedback == nil }) else {
            await UXLatencyLogger.feedbackRecordingFailed(id: id)
            return
        }
        
        interactions[index].feedback = Date()
        await UXLatencyLogger.feedbackRecorded(id: id)
    }
    
    /// Returns the latency for a specific interaction.
    /// - Parameter id: Unique identifier of the interaction.
    public func latency(for id: String, maxLatency: Double = 1.0) async -> TimeInterval? {
        guard let latency = interactions.first(where: { $0.id == id })?.latency else { return nil }
        await UXLatencyLogger.latencyComputed(id: id, latency: latency, maxLatency: maxLatency)
        return latency
    }
    
    /// Retrieves all tracked interactions.
    func getInteractions() -> [UXInteraction] {
        interactions
    }
    
    /// Clears all recorded interaction data.
    func clear() async {
        interactions.removeAll()
        await UXLatencyLogger.trackerReset()
    }
    
    public func logFinalSummary() {
        let snapshot = interactions
        let avg = UXLatencyStats.averageLatency(in: snapshot)
        let max = UXLatencyStats.maxLatency(in: snapshot)
        let count = snapshot.count
        let types = UXLatencyStats.interactionsByType(in: snapshot)

        debugPrint("📦 UX Latency Summary")
        debugPrint("• Total interactions: \(count)")
        debugPrint("• Average latency: \(String(format: "%.3f", avg))s")
        debugPrint("• Max latency: \(String(format: "%.3f", max))s")
        for (type, number) in types {
            debugPrint("• \(type): \(number)")
        }
    }
    
    /// Converts a list of interactions into CSV format.
    /// - Returns: CSV-formatted string with interaction metrics.
    public func exportCSV() -> String {
        var csv = "id,type,start,feedback,latency\n"
        interactions.forEach { interaction in
            let start = interaction.start.timeIntervalSince1970
            let feedback = interaction.feedback?.timeIntervalSince1970 ?? 0
            let latency = interaction.latency ?? 0
            csv += "\(interaction.id),tap,\(start),\(feedback),\(latency)\n"
        }
        return csv
    }
}
