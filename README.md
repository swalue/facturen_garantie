# GarantieFacturen

Universele SwiftUI-app voor iPhone, iPad en Mac (via Mac Catalyst) om garanties en facturen overzichtelijk bij te houden. Bonnen en factuurbestanden worden gelezen uit een map in iCloud Drive.

## Functies

- **Garanties**: product, winkel, aankoopdatum, garantietermijn, berekende vervaldatum, bedrag, serienummer en notities
- **Status per garantie**: Actief / Verloopt weldra / Verloopt binnekort / Verlopen, met afteller in dagen
- **Notificaties**: lokale melding een instelbaar aantal dagen vóór het aflopen van een garantie (standaard 30)
- **Facturen**: datum, bedrag, BTW, categorie, leverancier, beschrijving en optionele koppeling aan een garantie; gegroepeerd per jaar met totalen
- **iCloud Drive als bron**: kies één map in iCloud Drive; bonnen staan in `Bonnen/`, facturen in `Facturen/`; bestanden koppelen en direct openen vanuit de app
- **Export**: facturen als CSV (Nederlands formaat, `;`-gescheiden) en garantieoverzicht als PDF

## iCloud Drive-structuur

```
iCloud Drive/GarantieFacturen/
├── Bonnen/
└── Facturen/
```

Op Mac wordt iCloud Drive automatisch lokaal gesynchroniseerd. De app benadert de map via een beveiligde bookmark (security-scoped), niet via een server-API: in Instellingen kies je de map één keer met de documentkiezer.

## Openen en bouwen

1. Open `GarantieFacturen.xcodeproj` in Xcode 15 of hoger
2. Kies je eigen team bij Signing & Capabilities (automatische handtekening)
3. Draai op iPhone/iPad (simulator of device) of op Mac via Catalyst
4. In de app: Instellingen → "Kies iCloud Drive-map" → selecteer je `GarantieFacturen`-map in iCloud Drive

Vereist: iOS 17+ / macOS 14+. Stack: Swift 5, SwiftUI, SwiftData, UserNotifications.

## Structuur

- `GarantieFacturen/Models` — SwiftData-modellen (`GarantieItem`, `Factuur`)
- `GarantieFacturen/Services` — iCloud Drive-koppeling, notificaties, export
- `GarantieFacturen/Utilities` — pure logica (vervaldatum/status, CSV, formatters)
- `GarantieFacturen/Views` — SwiftUI-schermen (garanties, facturen, instellingen, componenten)
- `GarantieFacturenTests` — unittests voor garantieberekeningen en CSV-export

## Opmerking

Deze code is geschreven zonder Xcode-compile in de ontwikkelomgeving; voer daarom bij de eerste build in Xcode de tests uit (`Cmd+U`) om alles te verifiëren.
