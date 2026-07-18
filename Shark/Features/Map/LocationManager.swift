import Foundation
import CoreLocation

@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    var hasDismissedBanner = false

    var needsPermission: Bool {
        authorizationStatus == .notDetermined && !hasDismissedBanner
    }

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func dismissBanner() {
        hasDismissedBanner = true
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        print("📍 Location: lat \(newLocation.coordinate.latitude), lon \(newLocation.coordinate.longitude)")
        location = newLocation
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorized {
            startUpdating()
        }
    }
}
