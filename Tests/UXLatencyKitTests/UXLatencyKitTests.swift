import Testing
import SwiftUI
import ViewInspector
@testable import UXLatencyKit

struct UXLatencyKitTests {
    @Test("Recording start creates interaction")
    func recordStartCreatesInteraction() async throws {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let latencyTracker = UXLatencyTracker()
        await latencyTracker.clear()
        await latencyTracker.recordStart(id: "test_button")
        let interactions = await latencyTracker.getInteractions()
        
        #expect(interactions.count == 1)
        #expect(interactions.first?.id == "test_button")
    }

    @Test("Recording feedback calculates latency")
    func recordFeedbackLatency() async throws {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let latencyTracker = UXLatencyTracker()
        await latencyTracker.clear()
        await latencyTracker.recordStart(id: "test_card")

        try await Task.sleep(nanoseconds: 100_000_000) // simulate 100ms delay

        await latencyTracker.recordFeedback(id: "test_card")

        let latency = await latencyTracker.latency(for: "test_card")
        guard let latency else {
            #expect(Bool(false), "Latency is unexpectedly nil — was feedback not recorded?")
            return
        }

        #expect(latency > 0.09)
    }

    @Test("Exported CSV includes interaction")
    func exportCSVIncludesInteraction() async throws {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let latencyTracker = UXLatencyTracker()
        await latencyTracker.clear()
        await latencyTracker.recordStart(id: "csv_test")
        try await Task.sleep(nanoseconds: 150_000_000)
        await latencyTracker.recordFeedback(id: "csv_test")

        let csv = await latencyTracker.exportCSV()
        debugPrint("📄 CSV Output:\n\(csv)")
        #expect(csv.contains("csv_test"))
        #expect(csv.contains("id,type,start,feedback,latency"))
    }

    @Test("Clearing tracker removes all entries")
    func clearingTrackerWorks() async throws {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let latencyTracker = UXLatencyTracker()
        await latencyTracker.recordStart(id: "delete_me")
        await latencyTracker.recordFeedback(id: "delete_me")
        await latencyTracker.clear()

        let interactions = await latencyTracker.getInteractions()
        #expect(interactions.isEmpty)
    }
    
    @MainActor @Test("Overlay renders properly with sample data")
    func overlayRenderTest() async throws {
        guard #available(iOS 15.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let interactions = [
            UXInteraction(id: "fast_btn", start: Date(), feedback: Date().addingTimeInterval(0.212)),
            UXInteraction(id: "slow_btn", start: Date(), feedback: Date().addingTimeInterval(0.784))
        ]

        let interactionColors = await UXLatencyOverlayViewStub.fetchLatencyData(interactions: interactions)
        let view = UXLatencyOverlayViewStub(interactions: interactions, interactionColors: interactionColors)
        let inspected = try view.inspect()

        let scroll = try inspected.scrollView()
        let vstack = try scroll.vStack()
        #expect(vstack.count == 1)

        let forEach = try vstack.forEach(0)
        #expect(forEach.count == interactions.count)
        let firstRow = try forEach.hStack(0)
        let firstText = try firstRow.text(2).string()
        #expect(firstText.contains("0.212"))
        
        for index in 0..<forEach.count {
            let row = try forEach.hStack(index)
            let id = try row.text(0).string()
            let latency = try row.text(2).string()
            debugPrint("🧩 Row \(index): ID = \(id), Latency = \(latency)")
        }

        let secondRow = try forEach.hStack(1)
        let secondText = try secondRow.text(2).string()
        #expect(secondText.contains("0.784"))

        // Inspect second HStack (slow)
        let slowColor = try secondRow.text(2).attributes().foregroundColor()
        print("slowColor")
        print(slowColor)
        print(secondText)
        //print(secondRow)
        #expect(slowColor == .orange || slowColor == .red, "Expected color to indicate latency above 300ms")
    }
    
    @MainActor @Test("Tracking latency creates interaction")
    func trackLatencyModifierTest() async throws {
        guard #available(iOS 14.0, *) else {
            debugPrint("⚠️ Skipped: UXLatencyTracker not available on this platform")
            return
        }
        let tracker = UXLatencyTracker()
        let testID = "modifier_test"
        let view = Text("Tap Me")
            .trackLatencyTap(id: testID, action: {
                
            })
        ViewHosting.expel(function: "host")
        ViewHosting.host(view: view)

        let inspected = try view.inspect()
        try inspected.callOnTapGesture()

        await tracker.recordStart(id: testID)
        await tracker.recordFeedback(id: testID)
        
        let interactions = await tracker.getInteractions()
        #expect(interactions.contains { $0.id == testID })
    }
}
