import Foundation
import UIKit
import CoreLocation

protocol PageViewControllerDelegate : class{
    func numberofpage(atIndex : Int, current: CityEntity)
    func pageChangeTo(atIndex : Int, current: CityEntity)
    func afficherFavori(ville : CityEntity)
    func changerTitle(title : String)
    func mettrePosActuellePageControle()
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CLLocationManagerDelegate {

    var pageViewDelegate : PageViewControllerDelegate?
    var pageControl = UIPageControl()
    var pages : [UIViewController] = []
    var currentIndex = 0
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var listeCities : [CityEntity] = []
    var currentLocationAdded = false
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        _ = loadCitiesFromJson(context: leContexte)
        locationManager.delegate = self
        switch(locationManager.authorizationStatus){
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                break
            default:
                locationManager.requestWhenInUseAuthorization()
                break
        }
        self.dataSource = self
        self.delegate = self
        pageControl.frame = CGRect(x: 46, y: 796, width: 296, height: 26)
        self.view.addSubview(pageControl)
        listeCities = findFavoriteCitiesFromCoreData(context: leContexte)
        if(listeCities.count != 0){
            for i in 0..<listeCities.count{
                pages.append(HomeViewController.getInstance(ville : listeCities[i]))
            }

            self.pageViewDelegate?.numberofpage(atIndex: self.listeCities.count, current: listeCities[0])
            self.pageViewDelegate?.afficherFavori(ville: listeCities[0])
            self.pageViewDelegate?.changerTitle(title: listeCities[0].name!)
        }
        else{
            pages.append(HomeViewController.getInstanceNil())
            self.pageViewDelegate?.changerTitle(title: "Aucune ville en favori")
        }
        self.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
        super.viewDidLoad()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        updateUserLocation(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        default:
            print("Location access denied by user")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            if clError.code == .denied {
                // Location access denied by user
                print("Location access denied by user")
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
    }

    func updateUserLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) {

        fetchWeatherDataFromLonLat(context: self.leContexte, lon: lon, lat: lat) { resulat in
                    switch resulat{
                    case .success(let weatherData):
                        //A définir
                        DispatchQueue.main.async {
                            if(self.currentLocationAdded){
                                self.listeCities.remove(at: 0)
                                self.pages.remove(at: 0)
                            }
                            self.currentLocationAdded = true
                            self.listeCities.insert(weatherData.city!, at: 0)
                            self.pages.insert(HomeViewController.getInstance(ville: weatherData.city!), at: 0)
                            self.pageViewDelegate?.numberofpage(atIndex: self.listeCities.count, current: weatherData.city!)
                            self.pageViewDelegate?.afficherFavori(ville: weatherData.city!)
                            self.pageViewDelegate?.mettrePosActuellePageControle()
                            //self.pageViewDelegate?.changerTitle(title: weatherData.city!.name!)
                            self.setViewControllers([self.pages[0]], direction: .reverse, animated: true, completion: nil)
                        }
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard pages.count > previousIndex else {
            return nil
        }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return nil
        }
        guard pages.count > nextIndex else {
            return nil
        }
        return pages[nextIndex]
    }

//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return pages.count
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return 0
//    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentIndexPageViewController = pageViewController.viewControllers?.first
            as? HomeViewController {
            let index = pages.firstIndex(of: currentIndexPageViewController)!
            pageViewDelegate?.pageChangeTo(atIndex: index, current: listeCities[index])
            pageViewDelegate?.afficherFavori(ville: listeCities[index])
            pageViewDelegate?.changerTitle(title: listeCities[index].name!)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewControllerIndex = pages.firstIndex(of: pendingViewControllers[0]) else {
            return
        }
        currentIndex = viewControllerIndex
        pageControl.currentPage = viewControllerIndex
        title = pages[currentIndex].title
    }
}
