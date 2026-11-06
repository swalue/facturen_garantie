import Foundation
import SwiftData
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let prefix = "garantie-"
    private let dagenSleutel = "nl.swalue.garantiefacturen.notificatiedagen"
    let standaardDagen = 30

    private init() {}

    func machtigingAanvragen() async -> Bool {
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
            let settings = await center.notificationSettings()
            return settings.authorizationStatus == .authorized
        } catch {
            return false
        }
    }

    func dagenVanTevoren() -> Int {
        let waarde = UserDefaults.standard.integer(forKey: dagenSleutel)
        return waarde > 0 ? waarde : standaardDagen
    }

    func stelDagenVanTevoren(_ dagen: Int) {
        UserDefaults.standard.set(dagen, forKey: dagenSleutel)
    }

    func syncNotificaties(garanties: [GarantieItem]) async {
        let pending = await center.pendingNotificationRequests()
        let eigen = pending.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: eigen)
        let dagen = dagenVanTevoren()
        let nu = Date()
        for garantie in garanties {
            guard let fireDatum = Calendar.current.date(byAdding: .day, value: -dagen, to: garantie.vervaldatum), fireDatum > nu else { continue }
            let content = UNMutableNotificationContent()
            content.title = "Garantie verloopt"
            content.body = "\(garantie.naam) verloopt op \(Formatters.datum.string(from: garantie.vervaldatum))."
            content.sound = .default
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDatum)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: prefix + garantie.idString, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    func syncNaWijziging(context: ModelContext) async {
        let garanties = (try? context.fetch(FetchDescriptor<GarantieItem>())) ?? []
        await syncNotificaties(garanties: garanties)
    }
}
