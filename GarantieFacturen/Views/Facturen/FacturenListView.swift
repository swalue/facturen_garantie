import SwiftData
import SwiftUI

struct FacturenListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Factuur.datum, order: .reverse) private var facturen: [Factuur]
    @State private var zoektekst = ""
    @State private var nieuweFactuur = false

    var gegroepeerd: [(jaar: Int, facturen: [Factuur], totaal: Double)] {
        let gefilterd: [Factuur]
        if zoektekst.isEmpty {
            gefilterd = facturen
        } else {
            gefilterd = facturen.filter { factuur in
                factuur.leverancier.localizedCaseInsensitiveContains(zoektekst)
                    || factuur.beschrijving.localizedCaseInsensitiveContains(zoektekst)
                    || factuur.categorie.localizedCaseInsensitiveContains(zoektekst)
            }
        }
        let groepen = Dictionary(grouping: gefilterd) { $0.jaar }
        return groepen.map { key, value in
            (
                jaar: key,
                facturen: value.sorted { $0.datum > $1.datum },
                totaal: value.reduce(0) { $0 + $1.bedrag }
            )
        }
        .sorted { $0.jaar > $1.jaar }
    }

    var body: some View {
        List {
            ForEach(gegroepeerd, id: \.jaar) { groep in
                Section {
                    ForEach(groep.facturen) { factuur in
                        NavigationLink(value: factuur) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(factuur.leverancier.isEmpty ? factuur.beschrijving : factuur.leverancier)
                                        .font(.headline)
                                    Text("\(factuur.categorie) · \(Formatters.datum.string(from: factuur.datum))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(Formatters.bedrag(factuur.bedrag))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(factuur)
                                try? modelContext.save()
                            } label: {
                                Label("Verwijder", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("\(groep.jaar)")
                        Spacer()
                        Text("Totaal: \(Formatters.bedrag(groep.totaal))")
                    }
                }
            }
        }
        .navigationTitle("Facturen")
        .searchable(text: $zoektekst, prompt: "Zoek op leverancier of beschrijving")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    nieuweFactuur = true
                } label: {
                    Label("Nieuw", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $nieuweFactuur) {
            NavigationStack {
                FactuurFormView()
            }
        }
        .navigationDestination(for: Factuur.self) { factuur in
            FactuurDetailView(factuur: factuur)
        }
    }
}
