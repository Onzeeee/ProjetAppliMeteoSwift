//
//  ViewController.swift
//  AppliMeteo
//
//  Created by tplocal on 22/02/2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labelDateDuJour: UILabel!
    @IBOutlet weak var imageDeFond: UIImageView!
    @IBOutlet weak var boutonMenu: UIButton!
    @IBOutlet weak var boutonFavori: UIButton!
    @IBOutlet weak var imageDescriptionTemps: UIImageView!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var labelTempMaxMin: UILabel!
    @IBOutlet weak var labelTempRessenti: UILabel!
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let locationHandler = LocationHandler()
    
    var listeCities : [CityEntity] = []
    var pageActuelle : Int = 0;
    
    override func viewDidLoad() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action:
        #selector (swipeFunc(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer (swipeRight)
        let swipeLeft = UISwipeGestureRecognizer (target: self, action:
        #selector (swipeFunc(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer (swipeLeft)
        _ = loadCitiesFromJson(context: leContexte)
        boutonMenu.setBackgroundImage(UIImage(named: "menu.png"), for: .normal)
        labelDateDuJour.text = Date.now.formatted(date: .complete, time: .omitted)
        
        listeCities = findFavoriteCitiesFromCoreData(context: leContexte)
        
        updateUserLocation()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc func swipeFunc(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            let ville : CityEntity
            if(pageActuelle - 1 >= 0){
                pageActuelle -= 1
            }
            if(pageActuelle == 0){
                ville = listeCities[listeCities.count-1]
            }
            else{
                ville = listeCities[pageActuelle-1]
            }
            chargerLesDonneesVille(ville: ville)
            afficherFavori(ville: ville)
        }
        else if gesture.direction == .left {
            if(pageActuelle + 1 < listeCities.count){
                pageActuelle  += 1
            }
            chargerLesDonneesVille(ville: listeCities[pageActuelle-1])
            afficherFavori(ville: listeCities[pageActuelle-1])
        }
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
                            self.listeCities.append(weatherData.city!)
                            self.chargerLesDonneesVille(ville : self.listeCities[self.listeCities.count-1])
                            self.afficherFavori(ville : self.listeCities[self.listeCities.count-1])
                        }
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func chargerLesDonneesVille(ville : CityEntity){
        title = ville.name
        imageDescriptionTemps.image = UIImage(named: "\(ville.weatherData!.currentTemperatureForecast!.icon!).png")
        labelTemp.text = "\(String(Int(ville.weatherData!.currentTemperatureForecast!.temp)+1))°C"
        labelTempMaxMin.text = "\(String(Int((ville.weatherData?.currentTemperatureForecast!.temp_min)!)))°C / \(String(Int((ville.weatherData?.currentTemperatureForecast!.temp_max)!)+1))°C"
        labelTempRessenti.text = "Ressenti : \(String(Int((ville.weatherData?.currentTemperatureForecast!.feels_like)!)+1))°C"
    }
    
    func afficherFavori(ville : CityEntity){
        if(ville.favorite){
            boutonFavori.setBackgroundImage(UIImage(named: "favori_jaune.png"), for: .normal)
        }
        else{
            boutonFavori.setBackgroundImage(UIImage(named: "favori.png"), for: .normal)
        }
    }
    
    @IBAction func ajouterFavori(_ sender: Any) {
        if(pageActuelle == 0){
            toggleFavorite(city: listeCities[listeCities.count-1], context: leContexte)
            afficherFavori(ville: listeCities[listeCities.count-1])
        }
        else{
            toggleFavorite(city: listeCities[pageActuelle-1], context: leContexte)
            afficherFavori(ville: listeCities[pageActuelle-1])
        }
        
    }
}

