import XCTest

@testable import GarantieFacturen

final class CSVExportTests: XCTestCase {
    func testEscapeOmScheidingsteken() {
        XCTAssertEqual(CSVExport.escape("a;b"), "\"a;b\"")
    }

    func testEscapeOmQuotes() {
        XCTAssertEqual(CSVExport.escape("say \"hi\""), "\"say \"\"hi\"\"\"")
    }

    func testEscapePlatteTekstBlijftPlat() {
        XCTAssertEqual(CSVExport.escape("mals"), "mals")
    }

    func testBedragStringGebruiktKomma() {
        XCTAssertEqual(CSVExport.bedragString(12.3), "12,30")
        XCTAssertEqual(CSVExport.bedragString(0), "0,00")
    }

    func testFacturenCSVHeaderEnRij() {
        let rij = FactuurExportRow(
            datum: Date(timeIntervalSince1970: 1704067200),
            bedrag: 99.5,
            btwPercentage: 21,
            categorie: "Abonnement",
            leverancier: "Provider;X",
            beschrijving: "Maandbedrag",
            bestandsnaam: "factuur.pdf"
        )
        let csv = CSVExport.facturen([rij])
        let regels = csv.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        XCTAssertEqual(regels.first, "Datum;Bedrag;BTW %;Categorie;Leverancier;Beschrijving;Bestand")
        XCTAssertTrue(regels[1].starts(with: "2024-01-01;99,50;21;Abonnement;"))
        XCTAssertTrue(regels[1].contains("\"Provider;X\""))
        XCTAssertTrue(regels[1].hasSuffix(";factuur.pdf"))
        XCTAssertTrue(csv.hasSuffix("\n"))
    }

    func testFacturenCSVLegeLijstGeeftAlleenHeader() {
        let csv = CSVExport.facturen([])
        XCTAssertEqual(csv, "Datum;Bedrag;BTW %;Categorie;Leverancier;Beschrijving;Bestand\n")
    }
}
