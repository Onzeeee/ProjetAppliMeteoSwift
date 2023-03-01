//
//  ViewController.swift
//  AppliMeteo
//
//  Created by tplocal on 22/02/2023.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var labelDateDuJour: UILabel!
    @IBOutlet weak var imageDeFond: UIImageView!
    @IBOutlet weak var boutonMenu: UIButton!
    @IBOutlet weak var boutonFavori: UIButton!
    @IBOutlet weak var imageDescriptionTemps: UIImageView!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var labelTempMaxMin: UILabel!
    @IBOutlet weak var labelTempRessenti: UILabel!
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var ville : [CityEntity] = []
    var pageActuelle : Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        let dateString = dateFormatter.string(from: Date())
        labelDateDuJour.text = dateString.capitalized
        chargerLesDonneesVille(ville: ville[0])
        afficherFavori(ville: ville[0])
        // Do any additional setup after loading the view.
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
    
    public func afficherFavori(ville : CityEntity){
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
        toggleFavorite(city: ville[0], context: leContexte)
        afficherFavori(ville: ville[0])
    }

    static func getInstance(ville: CityEntity) -> HomeViewController {
        let vc = UIStoryboard (name: "Main", bundle:
                                nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.ville.append(ville)
        return vc
    }

}
