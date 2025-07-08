import SwiftUI
import ViewInspector
@testable import UXLatencyKit

@available(iOS 15.0, *)
@available(macOS 12.0, *)
struct UXLatencyOverlayViewStub: View {
    let interactions: [UXInteraction]
    let interactionColors: [String: Color]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(interactions) { interaction in
                    HStack {
                        Text(interaction.id).bold()
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
    }
    
    /// Retrieves interaction data from the shared tracker
    public static func fetchLatencyData(interactions: [UXInteraction]) async -> [String: Color] {
        var result: [String: Color] = [:]
        for interaction in interactions {
            result[interaction.id] = await interaction.color()
            print(interaction.id, ":", result[interaction.id] ?? .gray)
        }
        return result
    }
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
extension UXLatencyOverlayViewStub: Inspectable {}
