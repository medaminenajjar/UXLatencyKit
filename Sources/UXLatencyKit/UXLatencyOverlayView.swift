import SwiftUI

@available(iOS 15.0, *)
@available(macOS 12.0, *)
/// SwiftUI view displaying tracked latency data in a live overlay.
/// Useful for debugging and observing UX responsiveness in real time.
public struct UXLatencyOverlayView: View {
    @State private var interactions: [UXInteraction] = []
    @State private var interactionColors: [String: Color] = [:]

    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(interactions) { interaction in
                    HStack {
                        Text(interaction.id)
                            .bold()
                        Spacer()
                        Text(String(format: "%.3f sec", interaction.latency ?? 0))
                        .foregroundColor(interactionColors[interaction.id] ?? .gray)
                    }
                    .font(.caption)
                }
            }
            .padding()
        }
        .frame(maxWidth: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
        .task {
            await fetchLatencyData()
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            Task {
                await fetchLatencyData()
            }
        }
    }

    /// Retrieves interaction data from the shared tracker
    private func fetchLatencyData() async {
        let list = await UXLatencyTracker.shared.getInteractions()
        interactions = list
        var result: [String: Color] = [:]
        for interaction in list {
            result[interaction.id] = await interaction.color()
        }
        interactionColors = result
    }
}
