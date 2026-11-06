import SwiftData
import SwiftUI

struct GarantieFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let item: GarantieItem?

    @State private var naam = ""
    @State private var categorie = "Overig"
    @State private var winkel = ""
    @State private var aankoopdatum = Date()
    @State private var termijn = 24
    @State private var bedragTekst = ""
    @State private var serienummer = ""
    @State private var notities = ""

    private let categorieen = ["Elektronica", "Huishouden", "Keuken", "Gereedschap", "Overig"]

    init(item: GarantieItem? = nil) {
        self.item = item
        if let item {
            _naam = State(initialValue: item.naam)
            _categorie = State(initialValue: item.categorie.isEmpty ? "Overig" : item.categorie)
            _winkel = State(initialValue: item.winkel)
            _aankoopdatum = State(initialValue: item.aankoopdatum)
            _termijn = State(initialValue: item.garantietermijnMaanden)
            _bedragTekst = State(initialValue: item.bedrag > 0 ? String(format: "%.2f", item.bedrag) : "")
            _serienummer = State(initialValue: item.serienummer)
            _notities = State(initialValue: item.notities)
        }
    }

    var body: some View {
        Form {
            Section("Product") {
                TextField("Naam", text: $naam)
                Picker("Categorie", selection: $categorie) {
                    ForEach(categorieen, id: \.self) { Text($0) }
                }
                TextField("Winkel", text: $winkel)
                TextField("Serienummer", text: $serienummer)
            }
            Section("Aankoop en garantie") {
                DatePicker("Aankoopdatum", selection: $aankoopdatum, displayedComponents: .date)
                Stepper("Termijn: \(termijn) maanden", value: $termijn, in: 0...360)
                TextField("Bedrag (optioneel)", text: $bedragTekst)
                    .keyboardType(.decimalPad)
            }
            Section("Notities") {
                TextField("Notities", text: $notities, axis: .vertical)
            }
        }
        .navigationTitle(item == nil ? "Nieuwe garantie" : "Bewerk garantie")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuleer") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Opslaan") { opslaan() }
                    .disabled(naam.isEmpty)
            }
        }
    }

    private func opslaan() {
        let bedrag = Double(bedragTekst.replacingOccurrences(of: ",", with: ".")) ?? 0
        if let item {
            item.naam = naam
            item.categorie = categorie
            item.winkel = winkel
            item.aankoopdatum = aankoopdatum
            item.garantietermijnMaanden = termijn
            item.bedrag = bedrag
            item.serienummer = serienummer
            item.notities = notities
        } else {
            let nieuw = GarantieItem(
                naam: naam,
                categorie: categorie,
                winkel: winkel,
                aankoopdatum: aankoopdatum,
                garantietermijnMaanden: termijn,
                bedrag: bedrag,
                serienummer: serienummer,
                notities: notities
            )
            modelContext.insert(nieuw)
        }
        try? modelContext.save()
        Task { await NotificationService.shared.syncNaWijziging(context: modelContext) }
        dismiss()
    }
}
