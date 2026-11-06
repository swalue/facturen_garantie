import SwiftData
import SwiftUI

struct GarantiesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GarantieItem.aankoopdatum, order: .reverse) private var garanties: [GarantieItem]
    @State private var zoektekst = ""
    @State private var nieuwItem = false

    var gefilterd: [GarantieItem] {
        let gesorteerd = garanties.sorted { $0.vervaldatum < $1.vervaldatum }
        guard !zoektekst.isEmpty else { return gesorteerd }
        return gesorteerd.filter { item in
            item.naam.localizedCaseInsensitiveContains(zoektekst)
                || item.winkel.localizedCaseInsensitiveContains(zoektekst)
                || item.categorie.localizedCaseInsensitiveContains(zoektekst)
        }
    }

    var body: some View {
        List {
            ForEach(gefilterd) { item in
                NavigationLink(value: item) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.naam).font(.headline)
                            if !item.winkel.isEmpty {
                                Text(item.winkel).font(.caption).foregroundStyle(.secondary)
                            }
                            Text("Vervalt op \(Formatters.datum.string(from: item.vervaldatum))").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadge(status: item.status)
                            Text(Formatters.dagen(item.dagenTotVerval)).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        modelContext.delete(item)
                        try? modelContext.save()
                        Task { await NotificationService.shared.syncNaWijziging(context: modelContext) }
                    } label: {
                        Label("Verwijder", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Garanties")
        .searchable(text: $zoektekst, prompt: "Zoek op naam, winkel of categorie")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    nieuwItem = true
                } label: {
                    Label("Nieuw", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $nieuwItem) {
            NavigationStack {
                GarantieFormView()
            }
        }
        .navigationDestination(for: GarantieItem.self) { item in
            GarantieDetailView(item: item)
        }
    }
}
