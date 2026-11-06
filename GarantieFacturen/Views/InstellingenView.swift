import SwiftData
import SwiftUI

struct InstellingenView: View {
    @Query private var garanties: [GarantieItem]
    @Query private var facturen: [Factuur]
    @State private var driveService = iCloudDriveService.shared
    @State private var toonPicker = false
    @State private var exportCSV: DeelbaarBestand?
    @State private var exportPDF: DeelbaarBestand?
    @State private var dagenVanTevoren = NotificationService.shared.dagenVanTevoren()

    var body: some View {
        Form {
            Section("iCloud Drive") {
                if driveService.isGekoppeld, let url = driveService.mapURL {
                    LabeledContent("Gekoppelde map", value: url.lastPathComponent)
                    Text("Submappen: \(iCloudDriveService.bonnenSubmap), \(iCloudDriveService.facturenSubmap)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Nog geen map gekoppeld. Kies je map 'GarantieFacturen' in iCloud Drive.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button(driveService.isGekoppeld ? "Wijzig map" : "Kies iCloud Drive-map") {
                    toonPicker = true
                }
            }

            Section("Notificaties") {
                Stepper("Melding \(dagenVanTevoren) dagen vóór verval", value: $dagenVanTevoren, in: 7...90, step: 1)
                    .onChange(of: dagenVanTevoren) { _, nieuw in
                        NotificationService.shared.stelDagenVanTevoren(nieuw)
                        Task { await NotificationService.shared.syncNotificaties(garanties: garanties) }
                    }
            }

            Section("Exporteren") {
                Button {
                    if let url = ExportService.schrijfTijdelijkBestand(naam: "facturen.csv", inhoud: ExportService.facturenCSV(facturen)) {
                        exportCSV = DeelbaarBestand(url: url)
                    }
                } label: {
                    Label("Facturen als CSV", systemImage: "square.and.arrow.up")
                }
                Button {
                    if let url = ExportService.pdfTijdelijkBestand(garanties: garanties) {
                        exportPDF = DeelbaarBestand(url: url)
                    }
                } label: {
                    Label("Garantieoverzicht als PDF", systemImage: "square.and.arrow.up")
                }
            }

            Section("Over deze app") {
                LabeledContent("Garanties", value: "\(garanties.count)")
                LabeledContent("Facturen", value: "\(facturen.count)")
                Text("Bonnen en factuurbestanden worden gelezen uit de gekoppelde iCloud Drive-map.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Instellingen")
        .sheet(isPresented: $toonPicker) {
            DocumentPicker { url in
                _ = driveService.slaMapOp(url)
                toonPicker = false
            }
        }
        .sheet(item: $exportCSV) { bestand in
            ActivityView(items: [bestand.url])
        }
        .sheet(item: $exportPDF) { bestand in
            ActivityView(items: [bestand.url])
        }
    }
}
