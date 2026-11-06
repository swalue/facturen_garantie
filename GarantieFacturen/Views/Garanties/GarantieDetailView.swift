import SwiftData
import SwiftUI

struct GarantieDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: GarantieItem
    @State private var driveService = iCloudDriveService.shared
    @State private var kiesBon = false
    @State private var kiesFactuur = false
    @State private var bewerken = false

    var body: some View {
        Form {
            Section("Product") {
                Text(item.naam).font(.headline)
                if !item.winkel.isEmpty {
                    LabeledContent("Winkel", value: item.winkel)
                }
                if !item.serienummer.isEmpty {
                    LabeledContent("Serienummer", value: item.serienummer)
                }
                LabeledContent("Categorie", value: item.categorie)
            }

            Section("Garantie") {
                LabeledContent("Aankoopdatum", value: Formatters.datum.string(from: item.aankoopdatum))
                LabeledContent("Termijn", value: "\(item.garantietermijnMaanden) maanden")
                LabeledContent("Vervaldatum", value: Formatters.datum.string(from: item.vervaldatum))
                HStack {
                    Text("Status")
                    Spacer()
                    StatusBadge(status: item.status)
                }
                LabeledContent("Resterend", value: Formatters.dagen(item.dagenTotVerval))
                if item.bedrag > 0 {
                    LabeledContent("Bedrag", value: Formatters.bedrag(item.bedrag))
                }
            }

            Section("Bijlagen (iCloud Drive)") {
                if let bon = item.bonBestandsnaam {
                    Button {
                        driveService.openBestand(submap: iCloudDriveService.bonnenSubmap, bestandsnaam: bon)
                    } label: {
                        Label("Bon: \(bon)", systemImage: "doc")
                    }
                }
                Button {
                    kiesBon = true
                } label: {
                    Label(item.bonBestandsnaam == nil ? "Koppel bon" : "Wijzig bon", systemImage: "paperclip")
                }
                if let factuur = item.factuurBestandsnaam {
                    Button {
                        driveService.openBestand(submap: iCloudDriveService.facturenSubmap, bestandsnaam: factuur)
                    } label: {
                        Label("Factuur: \(factuur)", systemImage: "doc.text")
                    }
                }
                Button {
                    kiesFactuur = true
                } label: {
                    Label(item.factuurBestandsnaam == nil ? "Koppel factuur" : "Wijzig factuur", systemImage: "paperclip")
                }
                if !driveService.isGekoppeld {
                    Text("Koppel eerst een iCloud Drive-map via Instellingen.").font(.caption).foregroundStyle(.secondary)
                }
            }

            if !item.notities.isEmpty {
                Section("Notities") {
                    Text(item.notities)
                }
            }

            if !item.facturen.isEmpty {
                Section("Gekoppelde facturen") {
                    ForEach(item.facturen) { factuur in
                        Text(factuur.leverancier.isEmpty ? factuur.beschrijving : factuur.leverancier)
                    }
                }
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(item)
                    try? modelContext.save()
                    Task { await NotificationService.shared.syncNaWijziging(context: modelContext) }
                    dismiss()
                } label: {
                    Label("Verwijder garantie", systemImage: "trash")
                }
            }
        }
        .navigationTitle(item.naam)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Bewerk") {
                    bewerken = true
                }
            }
        }
        .sheet(isPresented: $kiesBon) {
            BestandslijstSheet(
                submap: iCloudDriveService.bonnenSubmap,
                bestanden: driveService.bestandenInSubmap(iCloudDriveService.bonnenSubmap)
            ) { naam in
                item.bonBestandsnaam = naam
                kiesBon = false
            }
        }
        .sheet(isPresented: $kiesFactuur) {
            BestandslijstSheet(
                submap: iCloudDriveService.facturenSubmap,
                bestanden: driveService.bestandenInSubmap(iCloudDriveService.facturenSubmap)
            ) { naam in
                item.factuurBestandsnaam = naam
                kiesFactuur = false
            }
        }
        .sheet(isPresented: $bewerken) {
            NavigationStack {
                GarantieFormView(item: item)
            }
        }
    }
}
