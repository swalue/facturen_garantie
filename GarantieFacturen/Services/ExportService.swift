import Foundation
import UIKit

enum ExportService {
    static func facturenCSV(_ facturen: [Factuur]) -> String {
        let rijen = facturen.map { factuur in
            FactuurExportRow(
                datum: factuur.datum,
                bedrag: factuur.bedrag,
                btwPercentage: factuur.btwPercentage,
                categorie: factuur.categorie,
                leverancier: factuur.leverancier,
                beschrijving: factuur.beschrijving,
                bestandsnaam: factuur.bestandsnaam ?? ""
            )
        }
        return CSVExport.facturen(rijen)
    }

    static func schrijfTijdelijkBestand(naam: String, inhoud: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(naam)
        try? inhoud.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    static func garantieOverzichtPDF(garanties: [GarantieItem]) -> Data? {
        let pagina = CGRect(x: 0, y: 0, width: 595, height: 842)
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, pagina, nil)

        var y: CGFloat = 60
        let marge: CGFloat = 40
        let regelHoogte: CGFloat = 18

        func nieuwePagina() {
            UIGraphicsBeginPDFPageWithInfo(pagina, nil)
            y = 60
        }

        func regel(_ tekst: String, lettertype: UIFont, kleur: UIColor) {
            tekst.draw(at: CGPoint(x: marge, y: y), withAttributes: [
                .font: lettertype,
                .foregroundColor: kleur,
            ])
        }

        nieuwePagina()
        regel("Garantieoverzicht", lettertype: .boldSystemFont(ofSize: 20), kleur: .black)
        y += 30
        regel("Gegenereerd op \(Formatters.datum.string(from: Date()))", lettertype: .systemFont(ofSize: 10), kleur: .gray)
        y += 24
        for garantie in garanties.sorted(by: { $0.vervaldatum < $1.vervaldatum }) {
            if y > pagina.height - 60 {
                nieuwePagina()
            }
            regel("\(garantie.naam) - \(garantie.status.label)", lettertype: .boldSystemFont(ofSize: 12), kleur: .black)
            y += regelHoogte
            regel("Aankoop: \(Formatters.datum.string(from: garantie.aankoopdatum)) | Vervalt: \(Formatters.datum.string(from: garantie.vervaldatum)) | \(Formatters.dagen(garantie.dagenTotVerval))", lettertype: .systemFont(ofSize: 10), kleur: .darkGray)
            y += regelHoogte + 6
        }
        UIGraphicsEndPDFContext()
        return data as Data
    }

    static func pdfTijdelijkBestand(garanties: [GarantieItem]) -> URL? {
        guard let data = garantieOverzichtPDF(garanties: garanties) else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("garantie-overzicht.pdf")
        try? data.write(to: url)
        return url
    }
}
