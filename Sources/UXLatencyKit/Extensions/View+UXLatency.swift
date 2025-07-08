import SwiftUI

@available(iOS 14.0, *)
@available(macOS 11.0, *)
/// Extension that enables latency tracking for any SwiftUI view.
/// Automatically records the interaction start on tap, and feedback on appear.
extension View {
    public func trackLatencyTap(id: String, action: @escaping () -> Void) -> some View {
        self
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    Task {
                        await UXLatencyTracker.shared.recordStart(id: id)
                        action()
                    }
                }
            )
    }
    
    public func trackLatencyFeedback(id: String) -> some View {
        self.onAppear {
            Task {
                await UXLatencyTracker.shared.recordFeedback(id: id)
            }
        }
    }
}
