import Foundation
import Observation
import UIKit

@Observable
final class iCloudDriveService {
    static let shared = iCloudDriveService()

    static let bonnenSubmap = "Bonnen"
    static let facturenSubmap = "Facturen"

    private let bookmarkSleutel = "nl.swalue.garantiefacturen.icloudmap"

    private(set) var mapURL: URL?

    var isGekoppeld: Bool { mapURL != nil }

    private init() {}

    @discardableResult
    func slaMapOp(_ url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else { return false }
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey: bookmarkSleutel)
            mapURL = url
            return true
        } catch {
            url.stopAccessingSecurityScopedResource()
            return false
        }
    }

    @discardableResult
    func herstelMap() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: bookmarkSleutel) else { return false }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
            if url.startAccessingSecurityScopedResource() {
                mapURL = url
                return true
            }
        } catch {
            return false
        }
        return false
    }

    func submapURL(_ naam: String) -> URL? {
        guard let mapURL else { return nil }
        let sub = mapURL.appendingPathComponent(naam, isDirectory: true)
        try? FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        return sub
    }

    func bestandenInSubmap(_ naam: String) -> [URL] {
        guard let sub = submapURL(naam) else { return [] }
        guard let urls = try? FileManager.default.contentsOfDirectory(at: sub, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else { return [] }
        return urls.filter { url in
            (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
        }.sorted { a, b in
            a.lastPathComponent.localizedCaseInsensitiveCompare(b.lastPathComponent) == .orderedAscending
        }
    }

    func bestandURL(submap: String, bestandsnaam: String) -> URL? {
        submapURL(submap)?.appendingPathComponent(bestandsnaam)
    }

    func openBestand(submap: String, bestandsnaam: String) {
        guard let url = bestandURL(submap: submap, bestandsnaam: bestandsnaam) else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        Task { @MainActor in
            UIApplication.shared.open(url) { _ in
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
}
