import SwiftUI

@main
struct SimpleTimeTrackerApp: App {
    @StateObject private var dataStore = DataStore()
    
    var body: some Scene {
        MenuBarExtra("Simple Time Tracker", systemImage: "clock") {
            ContentView()
                .environmentObject(dataStore)
        }
        .menuBarExtraStyle(.window)
    }
}

class DataStore: ObservableObject {
    @AppStorage("focuses") var focuses: [Focus] = []
}

typealias Focuses = [Focus]

extension Focuses: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct Time: Decodable, Encodable {
    let start: Double
    let length: Double
}

struct Focus: Decodable, Encodable, Identifiable {
    var id = UUID()
    let name: String
    var times: [Time] = []
    var isSelected: Bool = false
}

struct FocusChartData: Identifiable {
    var id = UUID()
    var day: String
    var minutes: Double
    var name: String
}


