import Foundation
import SwiftData

@Model
final class GarantieItem {
    var uniekeId: UUID
    var naam: String
    var categorie: String
    var winkel: String
    var aankoopdatum: Date
    var garantietermijnMaanden: Int
    var bedrag: Double
    var serienummer: String
    var notities: String
    var bonBestandsnaam: String?
    var factuurBestandsnaam: String?
    var aangemaaktOp: Date
    @Relationship(inverse: \Factuur.garantieItem) var facturen: [Factuur]

    init(
        naam: String,
        categorie: String = "Overig",
        winkel: String = "",
        aankoopdatum: Date = Date(),
        garantietermijnMaanden: Int = 24,
        bedrag: Double = 0,
        serienummer: String = "",
        notities: String = "",
        bonBestandsnaam: String? = nil,
        factuurBestandsnaam: String? = nil
    ) {
        self.uniekeId = UUID()
        self.naam = naam
        self.categorie = categorie
        self.winkel = winkel
        self.aankoopdatum = aankoopdatum
        self.garantietermijnMaanden = garantietermijnMaanden
        self.bedrag = bedrag
        self.serienummer = serienummer
        self.notities = notities
        self.bonBestandsnaam = bonBestandsnaam
        self.factuurBestandsnaam = factuurBestandsnaam
        self.aangemaaktOp = Date()
        self.facturen = []
    }

    var idString: String { uniekeId.uuidString }

    var vervaldatum: Date {
        GarantieBerekening.vervaldatum(aankoopdatum: aankoopdatum, termijnMaanden: garantietermijnMaanden)
    }

    var dagenTotVerval: Int {
        GarantieBerekening.dagenTotVerval(vervaldatum: vervaldatum)
    }

    var status: GarantieStatus {
        GarantieBerekening.status(dagenTotVerval: dagenTotVerval)
    }
}
