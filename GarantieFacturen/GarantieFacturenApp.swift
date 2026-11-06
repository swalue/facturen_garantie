import SwiftData
import SwiftUI

@main
struct GarantieFacturenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [GarantieItem.self, Factuur.self])
    }
}
