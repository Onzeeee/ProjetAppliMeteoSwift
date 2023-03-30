//
//  ViewControllerPourPageControl.swift
//  AppliMeteo
//
//  Created by tplocal on 01/03/2023.
//

import UIKit

protocol ViewControllerPourPageControlDelegate{
    func passageFrancais()
    func passageAnglais()
}

class ViewControllerPourPageControl: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    var delegate : ViewControllerPourPageControlDelegate?
    var customPageViewController: PageViewController!
    var currentCity : CityEntity!
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var boutonFavori: UIButton!
    var seuleVille = false
    @IBOutlet weak var fondPageControlFavoriMenu: UIView!
    let switchControl = UISwitch(frame: CGRect(x: 31, y: 6, width: 49, height: 31))
    var couleurFond : [String:UIColor] = [
        "01d":UIColor(red: 245/255, green: 239/255, blue: 215/255, alpha: 1),
        "01n":UIColor(red: 125/255, green: 140/255, blue: 149/255, alpha: 1),
        "02d":UIColor(red: 239/255, green: 236/255, blue: 227/255, alpha: 1),
        "02n":UIColor(red: 84/255, green: 83/255, blue: 96/255, alpha: 1),
        "03d":UIColor(red: 211/255, green: 213/255, blue: 222/255, alpha: 1),
        "03n":UIColor(red: 211/255, green: 213/255, blue: 222/255, alpha: 1),
        "04d":UIColor(red: 189/255, green: 196/255, blue: 197/255, alpha: 1),
        "04n":UIColor(red: 189/255, green: 196/255, blue: 197/255, alpha: 1),
        "09d":UIColor(red: 205/255, green: 210/255, blue: 210/255, alpha: 1),
        "09n":UIColor(red: 205/255, green: 210/255, blue: 210/255, alpha: 1),
        "10d":UIColor(red: 208/255, green: 226/255, blue: 231/255, alpha: 1),
        "10n":UIColor(red: 188/255, green: 206/255, blue: 211/255, alpha: 1),
        "11d":UIColor(red: 154/255, green: 185/255, blue: 194/255, alpha: 1),
        "11n":UIColor(red: 154/255, green: 185/255, blue: 194/255, alpha: 1),
        "13d":UIColor(red: 244/255, green: 243/255, blue: 230/255, alpha: 1),
        "13n":UIColor(red: 244/255, green: 243/255, blue: 230/255, alpha: 1),
        "50d":UIColor(red: 212/255, green: 226/255, blue: 223/255, alpha: 1),
        "50n":UIColor(red: 212/255, green: 226/255, blue: 223/255, alpha: 1)]
    var couleurPageControl : [String:UIColor] = [
        "01d":UIColor(red: 215/255, green: 209/255, blue: 185/255, alpha: 1),
        "01n":UIColor(red: 145/255, green: 160/255, blue: 169/255, alpha: 1),
        "02d":UIColor(red: 209/255, green: 206/255, blue: 197/255, alpha: 1),
        "02n":UIColor(red: 104/255, green: 103/255, blue: 116/255, alpha: 1),
        "03d":UIColor(red: 181/255, green: 183/255, blue: 192/255, alpha: 1),
        "03n":UIColor(red: 181/255, green: 183/255, blue: 192/255, alpha: 1),
        "04d":UIColor(red: 159/255, green: 166/255, blue: 167/255, alpha: 1),
        "04n":UIColor(red: 159/255, green: 166/255, blue: 167/255, alpha: 1),
        "09d":UIColor(red: 185/255, green: 190/255, blue: 190/255, alpha: 1),
        "09n":UIColor(red: 185/255, green: 190/255, blue: 190/255, alpha: 1),
        "10d":UIColor(red: 178/255, green: 196/255, blue: 201/255, alpha: 1),
        "10n":UIColor(red: 168/255, green: 186/255, blue: 191/255, alpha: 1),
        "11d":UIColor(red: 124/255, green: 155/255, blue: 164/255, alpha: 1),
        "11n":UIColor(red: 124/255, green: 155/255, blue: 164/255, alpha: 1),
        "13d":UIColor(red: 214/255, green: 213/255, blue: 200/255, alpha: 1),
        "13n":UIColor(red: 214/255, green: 213/255, blue: 200/255, alpha: 1),
        "50d":UIColor(red: 182/255, green: 196/255, blue: 193/255, alpha: 1),
        "50n":UIColor(red: 182/255, green: 196/255, blue: 193/255, alpha: 1)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let switchContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 44))
        let leftImage = UIImage(named: "france.png")
        let leftImageView = UIImageView(image: leftImage)
        leftImageView.frame = CGRect(x: 0, y: 13, width: 22, height: 18)
        switchContainerView.addSubview(leftImageView)
        let rightImage = UIImage(named: "UK.png")
        let rightImageView = UIImageView(image: rightImage)
        rightImageView.frame = CGRect(x: 88, y: 13, width: 22, height: 18)
        switchContainerView.addSubview(rightImageView)
        switchControl.onTintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 0.1)
        switchContainerView.addSubview(switchControl)
        let switchBarButton = UIBarButtonItem(customView: switchContainerView)
        switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = switchBarButton
        // Do any additional setup after loading the view.
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            delegate?.passageAnglais()
        } else {
            delegate?.passageFrancais()
        }
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
        delegate = customPageViewController
        }
    }
}

extension ViewControllerPourPageControl : PageViewControllerDelegate{
    
    func checkLangage() {
        if(switchControl.isOn){
            delegate?.passageAnglais()
        }
        else{
            delegate?.passageFrancais()
        }
    }
    
    
    func changerFondEcran(image: String) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn]) {
            if(self.couleurFond[image] == nil){
                self.view.backgroundColor = .white
                self.fondPageControlFavoriMenu.backgroundColor = .white
            }
            else{
                self.view.backgroundColor = self.couleurFond[image]
                self.fondPageControlFavoriMenu.backgroundColor = self.couleurPageControl[image]
            }
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
