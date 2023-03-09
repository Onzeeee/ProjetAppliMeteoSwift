import Foundation
import UIKit
import CoreLocation

protocol PageViewControllerDelegate : class{
    func numberofpage(atIndex : Int, current: CityEntity)
    func pageChangeTo(atIndex : Int, current: CityEntity)
    func afficherFavori(ville : CityEntity)
    func changerTitle(title : String)
    func mettrePosActuellePageControle()
//    func changerFondEcran(nomImage : String)
}

class PageViewController: UIPageViewController,
        UIPageViewControllerDataSource,
        UIPageViewControllerDelegate,
        CLLocationManagerDelegate{

    var pageViewDelegate : PageViewControllerDelegate?
    var currentIndex = 0
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var listeCities : [CityEntity] = []
    var cityViews: [Int32: HomeViewController] = [:]
    var currentCity : CityEntity?
    var currentLocationAdded = false
    let locationManager = CLLocationManager()
    var seuleVille = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(seuleVille){
            initFavoris(seule : seuleVille)
        }else{
            initFavoris(seule : seuleVille)
        }
    }

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
        super.viewDidLoad()
    }

    func initFavoris(seule : Bool){
        listeCities.removeAll()

        let favs = findFavoriteCitiesFromCoreData(context: leContexte)
        if(favs.count != 0){
            let oldindex = currentIndex
            // remove all pages except the first one

            if(currentCity != nil){
                self.currentLocationAdded = true
                listeCities.append(currentCity!)
                //pages.append(HomeViewController.getInstance(ville : currentCity!))
            }

            for i in 0..<favs.count{
                listeCities.append(favs[i])
                if(cityViews[favs[i].id] == nil){
                    cityViews[favs[i].id] = HomeViewController.getInstance(ville : favs[i])
                }
                //pages.append(HomeViewController.getInstance(ville : favs[i]))
            }
            var target = 0
            if(oldindex < listeCities.count){
                target = oldindex
            }
            self.currentIndex = target
            DispatchQueue.main.async() { [self] in
                self.pageViewDelegate?.numberofpage(atIndex: self.listeCities.count, current: self.listeCities[target])
                self.pageViewDelegate?.afficherFavori(ville: self.listeCities[target])
                self.pageViewDelegate?.changerTitle(title: self.listeCities[target].name!)
                self.pageViewDelegate?.pageChangeTo(atIndex: target, current: self.listeCities[target])
                self.setViewControllers([self.cityViews[self.listeCities[target].id]!], direction: .reverse, animated: true, completion: nil)
            }
        }
        else{
            // todo il se passe des trucs bizarre quand on supprime tous les favoris et qu'on revient sur la page
            if(currentCity != nil){
                listeCities.append(currentCity!)
                DispatchQueue.main.async() { [self] in
                    self.pageViewDelegate?.numberofpage(atIndex: 1, current: self.currentCity!)
                    self.pageViewDelegate?.afficherFavori(ville: self.currentCity!)
                    self.pageViewDelegate?.mettrePosActuellePageControle()
                    self.pageViewDelegate?.changerTitle(title: self.currentCity!.name!)
                    self.pageViewDelegate?.pageChangeTo(atIndex: 0, current: self.currentCity!)
                    self.setViewControllers([cityViews[self.currentCity!.id]!], direction: .reverse, animated: true, completion: nil)
                }
            }
            else{
                DispatchQueue.main.async() { [self] in
                    // todo changer le page control pour qu'il n'y ait qu'une page ( sans ville )
                    self.pageViewDelegate?.changerTitle(title: "Aucune ville en favori")
                    self.setViewControllers([HomeViewController.getInstanceNil()], direction: .reverse, animated: true, completion: nil)
                }
            }
        }
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
                //print("Failed to get location, retry after a delay")
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
        Task{
            do{
                let weatherData = try await fetchWeatherDataFromLonLat(context: self.leContexte, lon: lon, lat: lat)
                guard let city = weatherData.city else {
                    fatalError("City is nil : \(weatherData)")
                }
                DispatchQueue.main.async { [self] in
                    if(self.currentLocationAdded){
                        self.listeCities.remove(at: 0)
                        //self.pages.remove(at: 0)
                    }
                    self.currentLocationAdded = true
                    self.currentCity = city
                    self.listeCities.insert(city, at: 0)
                    self.pageViewDelegate?.numberofpage(atIndex: self.listeCities.count, current: city)
                    self.pageViewDelegate?.afficherFavori(ville: city)
                    self.pageViewDelegate?.mettrePosActuellePageControle()
                    self.pageViewDelegate?.changerTitle(title: city.name!)
                    self.cityViews[city.id] = HomeViewController.getInstance(ville: city)
                    self.setViewControllers([self.cityViews[city.id]!], direction: .reverse, animated: true, completion: nil)
                }
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let previousIndex = currentIndex - 1
        guard !(previousIndex < 0 || listeCities.count <= previousIndex) else {
            return nil
        }
        if(cityViews[listeCities[previousIndex].id] != nil){
            return cityViews[listeCities[previousIndex].id]
        }
        cityViews[listeCities[previousIndex].id] = HomeViewController.getInstance(ville: listeCities[previousIndex])
        return cityViews[listeCities[previousIndex].id]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextIndex = currentIndex + 1
        guard !(nextIndex < 0 || nextIndex >= listeCities.count) else {
            return nil
        }
        if(cityViews[listeCities[nextIndex].id] != nil){
            return cityViews[listeCities[nextIndex].id]
        }
        cityViews[listeCities[nextIndex].id] = HomeViewController.getInstance(ville: listeCities[nextIndex])
        return cityViews[listeCities[nextIndex].id]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageViewDelegate?.pageChangeTo(atIndex: currentIndex, current: listeCities[currentIndex])
        pageViewDelegate?.afficherFavori(ville: listeCities[currentIndex])
        pageViewDelegate?.changerTitle(title: listeCities[currentIndex].name!)
//        let icon = self.listeCities[currentIndex].weatherData?.currentTemperatureForecast?.icon!
//        let premiereLettre = icon![icon!.index((icon!.startIndex), offsetBy: 0)]
//        let deuxiemeLettre = icon![icon!.index((icon!.startIndex), offsetBy: 1)]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pendingViewControllers = pendingViewControllers as? [HomeViewController] else {
            return
        }
        if pendingViewControllers[0].ville.count == 0 {
            return
        }
        guard let viewControllerIndex = listeCities.firstIndex(of: pendingViewControllers[0].ville[0]) else {
            return
        }
        currentIndex = viewControllerIndex
        title = listeCities[currentIndex].name
    }
}

extension PageViewController : ViewControllerPourPageControlDelegate{

    func changePageControlPage(atIndex: Int) {
        DispatchQueue.main.async() {
            let direction: UIPageViewController.NavigationDirection = atIndex > self.currentIndex ? .forward : .reverse
            self.pageViewDelegate?.afficherFavori(ville: self.listeCities[atIndex])
            self.pageViewDelegate?.changerTitle(title: self.listeCities[atIndex].name!)
            if(self.cityViews[self.listeCities[atIndex].id] == nil){
                self.cityViews[self.listeCities[atIndex].id] = HomeViewController.getInstance(ville: self.listeCities[atIndex])
            }
            self.setViewControllers([self.cityViews[self.listeCities[atIndex].id]!], direction: direction, animated: true, completion: nil)
            self.currentIndex = atIndex
        }
    }

}
