import SwiftUI

@available(iOS 14.0, *)
@available(macOS 11.0, *)
extension Button {
    public func trackLatencyTap(id: String) -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded {
                Task {
                    await UXLatencyTracker.shared.recordStart(id: id)
                }
            }
        )
    }
}
