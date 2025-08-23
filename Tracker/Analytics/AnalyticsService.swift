import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}
    func reportEvent(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
