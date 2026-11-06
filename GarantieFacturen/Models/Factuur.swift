import Foundation
import SwiftData

enum FactuurCategorie: String, CaseIterable, Codable, Identifiable {
    case abonnement = "Abonnement"
    case eenmaligeAankoop = "Eenmalige aankoop"
    case huishouden = "Huishouden"
    case elektronica = "Elektronica"
    case overig = "Overig"

    var id: String { rawValue }
}

@Model
final class Factuur {
    var uniekeId: UUID
    var datum: Date
    var bedrag: Double
    var btwPercentage: Double
    var categorie: String
    var leverancier: String
    var beschrijving: String
    var bestandsnaam: String?
    var aangemaaktOp: Date
    @Relationship var garantieItem: GarantieItem?

    init(
        datum: Date = Date(),
        bedrag: Double = 0,
        btwPercentage: Double = 21,
        categorie: String = FactuurCategorie.overig.rawValue,
        leverancier: String = "",
        beschrijving: String = "",
        bestandsnaam: String? = nil,
        garantieItem: GarantieItem? = nil
    ) {
        self.uniekeId = UUID()
        self.datum = datum
        self.bedrag = bedrag
        self.btwPercentage = btwPercentage
        self.categorie = categorie
        self.leverancier = leverancier
        self.beschrijving = beschrijving
        self.bestandsnaam = bestandsnaam
        self.aangemaaktOp = Date()
        self.garantieItem = garantieItem
    }

    var btwBedrag: Double { bedrag * btwPercentage / 100 }

    var jaar: Int { Calendar.current.component(.year, from: datum) }
}
