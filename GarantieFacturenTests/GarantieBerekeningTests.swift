import XCTest

@testable import GarantieFacturen

final class GarantieBerekeningTests: XCTestCase {
    var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }

    func testVervaldatumVoegtMaandenToe() {
        let aankoop = calendar.date(from: DateComponents(year: 2024, month: 1, day: 15))!
        let verval = GarantieBerekening.vervaldatum(aankoopdatum: aankoop, termijnMaanden: 12, calendar: calendar)
        let comps = calendar.dateComponents([.year, .month, .day], from: verval)
        XCTAssertEqual(comps.year, 2025)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 15)
    }

    func testVervaldatumNulMaandenValtSamenMetAankoop() {
        let aankoop = calendar.date(from: DateComponents(year: 2024, month: 6, day: 10))!
        let verval = GarantieBerekening.vervaldatum(aankoopdatum: aankoop, termijnMaanden: 0, calendar: calendar)
        XCTAssertEqual(calendar.dateComponents([.year, .month, .day], from: verval), calendar.dateComponents([.year, .month, .day], from: aankoop))
    }

    func testDagenTotVerval() {
        let vandaag = calendar.date(from: DateComponents(year: 2024, month: 12, day: 16))!
        let verval = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        XCTAssertEqual(GarantieBerekening.dagenTotVerval(vandaag: vandaag, vervaldatum: verval, calendar: calendar), 30)
    }

    func testDagenTotVervalNegatiefNaVerval() {
        let vandaag = calendar.date(from: DateComponents(year: 2025, month: 1, day: 16))!
        let verval = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        XCTAssertEqual(GarantieBerekening.dagenTotVerval(vandaag: vandaag, vervaldatum: verval, calendar: calendar), -1)
    }

    func testStatusGrenzen() {
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: -1), .verlopen)
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: 0), .kritiek)
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: 29), .kritiek)
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: 30), .weldra)
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: 89), .weldra)
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: 90), .actief)
        XCTAssertEqual(GarantieBerekening.status(dagenTotVerval: 365), .actief)
    }
}
