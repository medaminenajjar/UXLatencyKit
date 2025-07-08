import Foundation
import os

@available(iOS 14.0, *)
@available(macOS 11.0, *)
/// Internal logger for UXLatencyKit.
/// Used for tracing interaction recording and latency metrics during instrumentation.
enum UXLatencyLogger {
    static let logger = Logger(subsystem: "com.app.UXLatencyKit", category: "Instrumentation")
    
    /// Generic log method with level control.
    static func log(_ message: String, level: LogLevel = .info) async {
        switch level {
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
    }

    // Example wrapper usages:
    static func interactionStarted(id: String) async {
        await log("🎬 Interaction started → \(id), type: tap", level: .debug)
    }

    static func feedbackRecorded(id: String) async {
        await log("✅ Feedback recorded → \(id)", level: .info)
    }

    static func latencyComputed(id: String, latency: TimeInterval, maxLatency: Double) async {
        let level: LogLevel = latency > maxLatency ? .critical : .info
        await log("📏 Latency → \(id): \(String(format: "%.3f", latency)) sec", level: level)
    }

    static func trackerReset() async {
        await log("🧹 Tracker cleared", level: .warning)
    }
    
    static func feedbackRecordingFailed(id: String) async {
        await log("❌ Failed to record feedback for interaction: \(id)", level: .error)
    }
}
