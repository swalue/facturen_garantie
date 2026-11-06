import Foundation

struct FactuurExportRow {
    let datum: Date
    let bedrag: Double
    let btwPercentage: Double
    let categorie: String
    let leverancier: String
    let beschrijving: String
    let bestandsnaam: String
}

enum CSVExport {
    static let scheidingsteken = ";"

    static func escape(_ waarde: String) -> String {
        var v = waarde
        if v.contains("\"") {
            v = v.replacingOccurrences(of: "\"", with: "\"\"")
        }
        if v.contains(scheidingsteken) || v.contains("\"") || v.contains("\n") || v.contains("\r") {
            v = "\"\(v)\""
        }
        return v
    }

    static func bedragString(_ bedrag: Double) -> String {
        String(format: "%.2f", bedrag).replacingOccurrences(of: ".", with: ",")
    }

    static func facturen(_ rijen: [FactuurExportRow]) -> String {
        var regels = ["Datum\(scheidingsteken)Bedrag\(scheidingsteken)BTW %\(scheidingsteken)Categorie\(scheidingsteken)Leverancier\(scheidingsteken)Beschrijving\(scheidingsteken)Bestand"]
        let datumFormatter = DateFormatter()
        datumFormatter.dateFormat = "yyyy-MM-dd"
        datumFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        for rij in rijen {
            let velden = [
                datumFormatter.string(from: rij.datum),
                bedragString(rij.bedrag),
                String(format: "%.0f", rij.btwPercentage).replacingOccurrences(of: ".", with: ","),
                rij.categorie,
                rij.leverancier,
                rij.beschrijving,
                rij.bestandsnaam,
            ]
            regels.append(velden.map(escape).joined(separator: scheidingsteken))
        }
        return regels.joined(separator: "\n") + "\n"
    }
}
