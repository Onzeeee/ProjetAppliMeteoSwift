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
    @IBOutlet weak var pageControl: UIPageControl!
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let locationHandler = LocationHandler()
    
    var listeCities : [CityEntity] = []
    var pageActuelle : Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        pageControl.setIndicatorImage(UIImage(systemName: "paperplane.fill"), forPage: 0)
        if(listeCities.count == 1){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE d MMMM"
            let dateString = dateFormatter.string(from: Date())
            labelDateDuJour.text = dateString.capitalized
            chargerLesDonneesVille(ville: listeCities[0])
        }
        else{
            let swipeRight = UISwipeGestureRecognizer(target: self, action:
            #selector (swipeFunc(gesture:)))
            swipeRight.direction = .right
            self.view.addGestureRecognizer (swipeRight)
            let swipeLeft = UISwipeGestureRecognizer (target: self, action:
            #selector (swipeFunc(gesture:)))
            swipeLeft.direction = .left
            self.view.addGestureRecognizer (swipeLeft)
            _ = loadCitiesFromJson(context: leContexte)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE d MMMM"
            let dateString = dateFormatter.string(from: Date())
            labelDateDuJour.text = dateString.capitalized
            
            listeCities = findFavoriteCitiesFromCoreData(context: leContexte)
            
            self.pageControl.numberOfPages = self.listeCities.count+1
            
            updateUserLocation()
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func swipeFunc(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            let ville : CityEntity
            if(pageActuelle - 1 >= 0){
                pageActuelle -= 1
            }
            ville = listeCities[pageActuelle]
            chargerLesDonneesVille(ville: ville)
            afficherFavori(ville: ville)
            pageControl.currentPage = pageActuelle
        }
        else if gesture.direction == .left {
            if(pageActuelle + 1 < listeCities.count){
                pageActuelle  += 1
            }
            chargerLesDonneesVille(ville: listeCities[pageActuelle])
            afficherFavori(ville: listeCities[pageActuelle])
            pageControl.currentPage = pageActuelle
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
                            self.listeCities.insert(weatherData.city!, at: 0)
                            self.chargerLesDonneesVille(ville : self.listeCities[self.pageActuelle])
                            self.afficherFavori(ville : self.listeCities[self.pageActuelle])
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
        let fullString = NSMutableAttributedString(string : "\(String(Int((ville.weatherData?.currentTemperatureForecast!.temp_min)!)))°C ")
        let imageUpArrow = NSTextAttachment()
        imageUpArrow.image = UIImage(systemName: "arrow.up")
        let imageUpArrowAttach = NSAttributedString(attachment: imageUpArrow)
        let imageDownArrow = NSTextAttachment()
        imageDownArrow.image = UIImage(systemName: "arrow.down")
        let imageDownArrowAttach = NSAttributedString(attachment: imageDownArrow)
        fullString.append(imageDownArrowAttach)
        fullString.append(NSAttributedString(string: " \(String(Int((ville.weatherData?.currentTemperatureForecast!.temp_max)!)+1))°C "))
        fullString.append(imageUpArrowAttach)
        
        labelTempMaxMin.attributedText = fullString
        labelTempRessenti.text = "Ressenti : \(String(Int((ville.weatherData?.currentTemperatureForecast!.feels_like)!)+1))°C"
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
    
    @IBAction func ajouterFavori(_ sender: Any) {
        toggleFavorite(city: listeCities[pageActuelle], context: leContexte)
        afficherFavori(ville: listeCities[pageActuelle])
    }
}

