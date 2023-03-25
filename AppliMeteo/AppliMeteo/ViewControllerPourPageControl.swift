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
    @IBOutlet weak var boutonFavori: UIButton!
    var seuleVille = false
    @IBOutlet weak var fondPageControlFavoriMenu: UIView!
    var couleurFond : [String:UIColor] = [
        "01d":UIColor(red: 245/255, green: 239/255, blue: 215/255, alpha: 1),
        "01n":UIColor(red: 125/255, green: 140/255, blue: 149/255, alpha: 1),
        "02d":UIColor(red: 239/255, green: 236/255, blue: 227/255, alpha: 1),
        "02n":UIColor(red: 84/255, green: 83/255, blue: 96/255, alpha: 1),
        "03d":UIColor(red: 211/255, green: 213/255, blue: 222/255, alpha: 1),
        "03n":UIColor(red: 211/255, green: 213/255, blue: 222/255, alpha: 1),
        "04d":UIColor(red: 189/255, green: 196/255, blue: 197/255, alpha: 1),
        "04n":UIColor(red: 189/255, green: 196/255, blue: 197/255, alpha: 1),
        "09d":.white,
        "09n":.white,
        "10d":UIColor(red: 208/255, green: 226/255, blue: 231/255, alpha: 1),
        "10n":.white,
        "11d":.white,
        "11n":.white,
        "13d":.systemMint,
        "13n":.systemMint,
        "50d":.white,
        "50n":.white]
    var couleurPageControl : [String:UIColor] = [
        "01d":UIColor(red: 215/255, green: 209/255, blue: 185/255, alpha: 1),
        "01n":UIColor(red: 145/255, green: 160/255, blue: 169/255, alpha: 1),
        "02d":UIColor(red: 209/255, green: 206/255, blue: 197/255, alpha: 1),
        "02n":UIColor(red: 104/255, green: 103/255, blue: 116/255, alpha: 1),
        "03d":UIColor(red: 181/255, green: 183/255, blue: 192/255, alpha: 1),
        "03n":UIColor(red: 181/255, green: 183/255, blue: 192/255, alpha: 1),
        "04d":UIColor(red: 159/255, green: 166/255, blue: 167/255, alpha: 1),
        "04n":UIColor(red: 159/255, green: 166/255, blue: 167/255, alpha: 1),
        "09d":.white,
        "09n":.white,
        "10d":UIColor(red: 178/255, green: 196/255, blue: 201/255, alpha: 1),
        "10n":.white,
        "11d":.white,
        "11n":.white,
        "13d":.systemMint,
        "13n":.systemMint,
        "50d":.white,
        "50n":.white]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ajouterFavori(_ sender: Any) {
        let listeCities = findFavoriteCitiesFromCoreData(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        if(listeCities.count == 15){
            let alertController = UIAlertController(title: "Attention", message: "Vous avez un maximum de 15 favoris.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in}
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            toggleFavorite(city: currentCity, context: leContexte)
            afficherFavori(ville: currentCity)
        }
    }
    
    func changerCouleurPageControl(image : String){
        fondPageControlFavoriMenu.backgroundColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PageViewController {
        customPageViewController = destinationViewController
        customPageViewController.pageViewDelegate = self
        }
    }
}

extension ViewControllerPourPageControl : PageViewControllerDelegate{
    
    func changerFondEcran(image: String) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn]) {
            self.view.backgroundColor = self.couleurFond[image]
            self.fondPageControlFavoriMenu.backgroundColor = self.couleurPageControl[image]
        }
    }
    
    
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
