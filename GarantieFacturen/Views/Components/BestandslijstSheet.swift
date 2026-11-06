import SwiftUI

struct BestandslijstSheet: View {
    let submap: String
    let bestanden: [URL]
    let onKies: (String) -> Void

    var body: some View {
        NavigationStack {
            List(bestanden, id: \.self) { url in
                Button(url.lastPathComponent) {
                    onKies(url.lastPathComponent)
                }
            }
            .navigationTitle("Kies bestand uit \(submap)")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if bestanden.isEmpty {
                    ContentUnavailableView(
                        "Geen bestanden",
                        systemImage: "doc.badge.plus",
                        description: Text("Plaats bestanden in de submap '\(submap)' van de gekoppelde iCloud Drive-map.")
                    )
                }
            }
        }
    }
}
