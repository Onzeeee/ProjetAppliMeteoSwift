import Foundation
import UIKit


protocol PageViewControllerDelegate : class{
    func numberofpage(atIndex : Int, current: CityEntity)
    func pageChangeTo(atIndex : Int, current: CityEntity)
    func afficherFavori(ville : CityEntity)
    func changerTitle(title : String)
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewDelegate : PageViewControllerDelegate?
    var pageControl = UIPageControl()
    var pages : [UIViewController] = []
    var currentIndex = 0
    let locationHandler = LocationHandler()
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var listeCities : [CityEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = loadCitiesFromJson(context: leContexte)
        self.dataSource = self
        self.delegate = self
        pageControl.frame = CGRect(x: 46, y: 796, width: 296, height: 26)
        self.view.addSubview(pageControl)
        listeCities = findFavoriteCitiesFromCoreData(context: leContexte)
        for i in 0..<listeCities.count{
            pages.append(HomeViewController.getInstance(ville : listeCities[i]))
        }
        updateUserLocation()
    }
    
    func updateUserLocation() {
        locationHandler.getUserLocation { (location) in
            if location == nil{
                print("Pas de position")
            }
            else{
                let locationBis = location
                fetchWeatherDataFromLonLat(context: self.leContexte, lon: locationBis!.coordinate.longitude, lat: locationBis!.coordinate.latitude) { resulat in
                    switch resulat{
                    case .success(let weatherData):
                        //A définir
                        DispatchQueue.main.async {
                            self.listeCities.insert(weatherData.city!, at: 0)
                            self.pages.insert(HomeViewController.getInstance(ville: weatherData.city!), at: 0)
                            self.pageViewDelegate?.numberofpage(atIndex: self.listeCities.count, current: weatherData.city!)
                            self.pageViewDelegate?.afficherFavori(ville: weatherData.city!)
                            self.pageViewDelegate?.changerTitle(title: weatherData.city!.name!)
                            self.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
                        }
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
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
