import SwiftData
import SwiftUI

struct FactuurFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \GarantieItem.naam) private var garanties: [GarantieItem]

    let factuur: Factuur?

    @State private var datum = Date()
    @State private var bedragTekst = ""
    @State private var btw = 21.0
    @State private var categorie = FactuurCategorie.overig.rawValue
    @State private var leverancier = ""
    @State private var beschrijving = ""
    @State private var garantieID: String?

    init(factuur: Factuur? = nil) {
        self.factuur = factuur
        if let factuur {
            _datum = State(initialValue: factuur.datum)
            _bedragTekst = State(initialValue: factuur.bedrag > 0 ? String(format: "%.2f", factuur.bedrag) : "")
            _btw = State(initialValue: factuur.btwPercentage)
            _categorie = State(initialValue: factuur.categorie)
            _leverancier = State(initialValue: factuur.leverancier)
            _beschrijving = State(initialValue: factuur.beschrijving)
            _garantieID = State(initialValue: factuur.garantieItem?.idString)
        }
    }

    var body: some View {
        Form {
            Section("Factuurgegevens") {
                DatePicker("Datum", selection: $datum, displayedComponents: .date)
                TextField("Bedrag", text: $bedragTekst)
                    .keyboardType(.decimalPad)
                Stepper("BTW: \(Int(btw))%", value: $btw, in: 0...100, step: 1)
                Picker("Categorie", selection: $categorie) {
                    ForEach(FactuurCategorie.allCases) { cat in
                        Text(cat.rawValue).tag(cat.rawValue)
                    }
                }
                TextField("Leverancier", text: $leverancier)
                TextField("Beschrijving", text: $beschrijving)
            }
            Section("Koppeling (optioneel)") {
                Picker("Garantie", selection: $garantieID) {
                    Text("Geen").tag(String?.none)
                    ForEach(garanties) { garantie in
                        Text(garantie.naam).tag(Optional(garantie.idString))
                    }
                }
            }
        }
        .navigationTitle(factuur == nil ? "Nieuwe factuur" : "Bewerk factuur")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuleer") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Opslaan") { opslaan() }
                    .disabled(leverancier.isEmpty && beschrijving.isEmpty && bedragTekst.isEmpty)
            }
        }
    }

    private func opslaan() {
        let bedrag = Double(bedragTekst.replacingOccurrences(of: ",", with: ".")) ?? 0
        let gekoppeldeGarantie = garanties.first { $0.idString == garantieID }
        if let factuur {
            factuur.datum = datum
            factuur.bedrag = bedrag
            factuur.btwPercentage = btw
            factuur.categorie = categorie
            factuur.leverancier = leverancier
            factuur.beschrijving = beschrijving
            factuur.garantieItem = gekoppeldeGarantie
        } else {
            let nieuw = Factuur(
                datum: datum,
                bedrag: bedrag,
                btwPercentage: btw,
                categorie: categorie,
                leverancier: leverancier,
                beschrijving: beschrijving,
                garantieItem: gekoppeldeGarantie
            )
            modelContext.insert(nieuw)
        }
        try? modelContext.save()
        dismiss()
    }
}
