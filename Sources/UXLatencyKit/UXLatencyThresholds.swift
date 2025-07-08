import SwiftUI

@available(iOS 13.0, *)
@available(macOS 11.0, *)
public struct UXLatencyThresholds: Sendable {
    public var greenLimit: TimeInterval
    public var orangeLimit: TimeInterval
    public var colorForNil: Color

    public init(greenLimit: TimeInterval = 0.4, orangeLimit: TimeInterval = 0.9, colorForNil: Color = .gray) {
        self.greenLimit = greenLimit
        self.orangeLimit = orangeLimit
        self.colorForNil = colorForNil
    }

    public func color(for latency: TimeInterval?) -> Color {
        guard let latency else { return colorForNil }
        switch latency {
        case ..<greenLimit: return .green
        case ..<orangeLimit: return .orange
        default: return .red
        }
    }
}
