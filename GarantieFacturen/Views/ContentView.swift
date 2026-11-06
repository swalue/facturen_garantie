import SwiftData
import SwiftUI

struct ContentView: View {
    @Query private var garanties: [GarantieItem]
    @State private var driveService = iCloudDriveService.shared

    var body: some View {
        TabView {
            NavigationStack {
                GarantiesListView()
            }
            .tabItem {
                Label("Garanties", systemImage: "shield.checkered")
            }

            NavigationStack {
                FacturenListView()
            }
            .tabItem {
                Label("Facturen", systemImage: "doc.text")
            }

            NavigationStack {
                InstellingenView()
            }
            .tabItem {
                Label("Instellingen", systemImage: "gear")
            }
        }
        .task {
            driveService.herstelMap()
            await NotificationService.shared.machtigingAanvragen()
            await NotificationService.shared.syncNotificaties(garanties: garanties)
        }
    }
}
