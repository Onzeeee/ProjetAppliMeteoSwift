//
//  ViewControllerPourPageControl.swift
//  AppliMeteo
//
//  Created by tplocal on 01/03/2023.
//

import UIKit

class ViewControllerPourPageControl: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    var customPageViewController: PageViewController!
    var currentCity : CityEntity!
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var imageFond: UIImageView!
    @IBOutlet weak var boutonFavori: UIButton!
    var seuleVille = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ajouterFavori(_ sender: Any) {
        let listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        if(listeCities.count == 9){
            let alertController = UIAlertController(title: "Attention", message: "Vous avez un maximum de 9 favoris.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in}
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            toggleFavorite(city: currentCity, context: leContexte)
            afficherFavori(ville: currentCity)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PageViewController {
        customPageViewController = destinationViewController
        customPageViewController.pageViewDelegate = self
        }
    }
}

extension ViewControllerPourPageControl : PageViewControllerDelegate{
    
    func numberofpage(atIndex: Int, current: CityEntity) {
        pageControl.numberOfPages = atIndex
        currentCity = current
    }
    
    func pageChangeTo(atIndex: Int, current: CityEntity) {
        pageControl.currentPage = atIndex
        currentCity = current
    }
    
    func afficherFavori(ville : CityEntity){
        if(ville.favorite){
            boutonFavori.setImage(UIImage(systemName: "star.fill"), for: .normal)
            boutonFavori.tintColor = .systemYellow
        }
        else{
            boutonFavori.setImage(UIImage(systemName: "star"), for: .normal)
            boutonFavori.tintColor = .systemYellow
        }
    }
    
    func changerTitle(title : String){
        self.title = title
    }
    
    func mettrePosActuellePageControle(){
        pageControl.setIndicatorImage(UIImage(systemName: "paperplane.fill"), forPage: 0)
    }
}
