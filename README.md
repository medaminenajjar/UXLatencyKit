# 📦 UXLatencyKit

Measure the **real user experience latency** between intention and visual feedback in SwiftUI apps.  
UXLatencyKit helps you identify subtle delays, optimize responsiveness, and make your interfaces feel buttery smooth.

---

## 🚀 Overview

Every animation and transition matters — but so does the time it takes for your app to **react** after a user taps, scrolls, or drags.  
UXLatencyKit records the start of an interaction and the moment visual feedback appears, allowing you to:

- Detect sluggish UI behaviors
- Optimize perceived performance
- Improve animation timing
- Export latency metrics for analysis

---

## 🔧 Features

- ⏱ Track interaction latency (`start → visual response`)
- 🧪 Works with tap, drag, scroll, and custom events
- 📊 Live overlay showing latency per component
- 📤 CSV exporter for QA or performance dashboards
- ✅ Built with Swift Concurrency (`actor` architecture)
- 🔌 Easy SwiftUI integration with `.trackLatencyTap(id:) and .trackLatencyFeedback(id:)`

---

## 📦 Installation

Add via Swift Package Manager:

```swift
.package(url: "https://github.com/yourusername/UXLatencyKit.git", from: "1.0.0")
```

Then import:

```swift
import UXLatencyKit
```

## 🔤 Usage Example

Instrument any SwiftUI component to track latency between user interaction and visual feedback:

```swift
Button("Login") {
    Task {
        await UXLatencyTracker.shared.recordStart(id: "login_button")
        isLoggedIn = true
    }
}

if isLoggedIn {
    HomeView()
    .onAppear {
        Task {
            await UXLatencyTracker.shared.recordFeedback(id: "login_button")
        }
    }
}
```

✅ This setup records when the user taps the button and when the destination view appears, allowing you to measure the transition latency.

You also have access to view modifiers:

```swift
Button("Login") {
    // Your action
}
.trackLatencyTap(id: "login_button")
```

And feedback tracking:

```swift
HomeView()
    .trackLatencyFeedback(id: "login_button")
```

➡️ Automatically records tap time and feedback time when the view appears.

Show live metrics

```swift
UXLatencyOverlayView()
```

📄 Logging Output:

After tracking interactions, call the following to print a full latency summary:
```swift
UXLatencyTracker.shared.logFinalSummary()
```

🧾 Output will look like this in the console:

📦 UX Latency Summary
• Total interactions: 20
• Average latency: 0.147s
• Max latency: 0.348s
• tap: 20

UXLatencyKit prints latency values directly to the console in CSV format:

login_button,tap,1751831103.139937,1751831103.342156,0.20221900939941406

Export to CSV
```swift
let csv = UXLatencyTracker.shared.exportCSV()
```

## 📚 Use Cases
Detect slow visual feedback in animations or transitions

Optimize UX timing across multiple screens

Gather data from real device interaction tests

Build automated latency benchmarks per release


## 📚 Contributing
Want to contribute a new component or improvement?

Fork the repo

Create a feature branch

Open a pull request ✨

## 📣 License
MIT

Crafted with performance in mind ⚡ Made by @amine — contributions welcome!
