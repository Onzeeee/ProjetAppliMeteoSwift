//
// Created by Pierre Zachary on 24/02/2023.
//

import CoreLocation

final class LocationHandler: NSObject, CLLocationManagerDelegate {

    typealias LocationCompletionHandler = (CLLocation?) -> Void

    var locationManager: CLLocationManager!
    var locationCompletionHandler: LocationCompletionHandler?

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }



    @available(*, deprecated, message: "Implement CLLocationManagerDelegate instead")
    func getUserLocation(completion: @escaping LocationCompletionHandler) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("requesting authorization...")
            locationManager.requestWhenInUseAuthorization()
            locationCompletionHandler = completion
            break
        case .restricted, .denied:
            print("Location access denied or restricted")
            completion(nil)
            break
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access authorized")
            locationManager.startUpdatingLocation()
            locationCompletionHandler = completion
            break
        @unknown default:
            fatalError()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        locationCompletionHandler?(location)
        locationCompletionHandler = nil
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            if clError.code == .denied {
                // Location access denied by user
                print("Location access denied by user")
                locationCompletionHandler?(nil)
                locationCompletionHandler = nil
                return
            } else if clError.code == .locationUnknown {
                // Failed to get location, retry after a delay
                print("Failed to get location, retry after a delay")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    manager.requestLocation()
                }
                return
            }
        }
        // Handle other errors
        print("Failed to get location: \(error.localizedDescription)")
        locationCompletionHandler?(nil)
        locationCompletionHandler = nil
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        default:
            locationCompletionHandler?(nil)
            locationCompletionHandler = nil
        }
    }
}
