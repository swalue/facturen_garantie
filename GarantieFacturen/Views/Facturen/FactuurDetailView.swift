import SwiftData
import SwiftUI

struct FactuurDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var factuur: Factuur
    @State private var driveService = iCloudDriveService.shared
    @State private var kiesBestand = false
    @State private var bewerken = false

    var body: some View {
        Form {
            Section("Factuur") {
                if !factuur.leverancier.isEmpty {
                    LabeledContent("Leverancier", value: factuur.leverancier)
                }
                LabeledContent("Datum", value: Formatters.datum.string(from: factuur.datum))
                LabeledContent("Bedrag", value: Formatters.bedrag(factuur.bedrag))
                LabeledContent("BTW", value: "\(Int(factuur.btwPercentage))% (\(Formatters.bedrag(factuur.btwBedrag)))")
                LabeledContent("Categorie", value: factuur.categorie)
                if !factuur.beschrijving.isEmpty {
                    LabeledContent("Beschrijving", value: factuur.beschrijving)
                }
            }

            Section("Bijlage (iCloud Drive)") {
                if let naam = factuur.bestandsnaam {
                    Button {
                        driveService.openBestand(submap: iCloudDriveService.facturenSubmap, bestandsnaam: naam)
                    } label: {
                        Label(naam, systemImage: "doc.text")
                    }
                }
                Button {
                    kiesBestand = true
                } label: {
                    Label(factuur.bestandsnaam == nil ? "Koppel factuurbestand" : "Wijzig bestand", systemImage: "paperclip")
                }
                if !driveService.isGekoppeld {
                    Text("Koppel eerst een iCloud Drive-map via Instellingen.").font(.caption).foregroundStyle(.secondary)
                }
            }

            if let garantie = factuur.garantieItem {
                Section("Gekoppeld aan garantie") {
                    Text(garantie.naam)
                }
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(factuur)
                    try? modelContext.save()
                    dismiss()
                } label: {
                    Label("Verwijder factuur", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Factuur")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Bewerk") {
                    bewerken = true
                }
            }
        }
        .sheet(isPresented: $kiesBestand) {
            BestandslijstSheet(
                submap: iCloudDriveService.facturenSubmap,
                bestanden: driveService.bestandenInSubmap(iCloudDriveService.facturenSubmap)
            ) { naam in
                factuur.bestandsnaam = naam
                kiesBestand = false
            }
        }
        .sheet(isPresented: $bewerken) {
            NavigationStack {
                FactuurFormView(factuur: factuur)
            }
        }
    }
}
