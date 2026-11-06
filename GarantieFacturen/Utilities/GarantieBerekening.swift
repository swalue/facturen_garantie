import Foundation

enum GarantieStatus: String, Codable, CaseIterable {
    case actief
    case weldra
    case kritiek
    case verlopen

    var label: String {
        switch self {
        case .actief: return "Actief"
        case .weldra: return "Verloopt weldra"
        case .kritiek: return "Verloopt binnekort"
        case .verlopen: return "Verlopen"
        }
    }
}

enum GarantieBerekening {
    static func vervaldatum(aankoopdatum: Date, termijnMaanden: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .month, value: termijnMaanden, to: aankoopdatum) ?? aankoopdatum
    }

    static func dagenTotVerval(vandaag: Date = Date(), vervaldatum: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: vandaag)
        let eind = calendar.startOfDay(for: vervaldatum)
        return calendar.dateComponents([.day], from: start, to: eind).day ?? 0
    }

    static func status(dagenTotVerval: Int) -> GarantieStatus {
        switch dagenTotVerval {
        case ..<0:
            return .verlopen
        case 0..<30:
            return .kritiek
        case 30..<90:
            return .weldra
        default:
            return .actief
        }
    }
}
