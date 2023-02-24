//
// Created by Pierre Zachary on 24/02/2023.
//

import CoreLocation

final class LocationHandler: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func getUserLocation() -> CLLocation? {
        switch locationManager.authorizationStatus {
            case .notDetermined:
                // Request authorization
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // Handle denied or restricted authorization
                print("Location access denied or restricted")
                break
            case .authorizedAlways, .authorizedWhenInUse:
                // Access user location
                let currentLocation = locationManager.location
                return currentLocation
            @unknown default:
                fatalError()
        }
        return nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
