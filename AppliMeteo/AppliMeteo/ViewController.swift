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
//        afficherFavori(ville: ville[0])
        // Do any additional setup after loading the view.
    }
    
    func chargerLesDonneesVille(ville : CityEntity){
        title = ville.name
        if(ville.weatherData == nil){
            print("pas de donnée météo")
            fetchWeatherDataFromLonLat(context: leContexte, lon: ville.lon, lat: ville.lat) { result in
                switch result{
                case .success(let weatherData):
                    print("weatherData trouvée")
                    DispatchQueue.main.async {
                        self.imageDescriptionTemps.image = UIImage(named: "\(weatherData.currentTemperatureForecast!.icon!).png")
                        self.labelTemp.text = "\(String(Int(weatherData.currentTemperatureForecast!.temp)+1))°C"
                        let fullString = NSMutableAttributedString(string : "\(String(Int((weatherData.currentTemperatureForecast!.temp_min))))°C ")
                        let imageUpArrow = NSTextAttachment()
                        imageUpArrow.image = UIImage(systemName: "arrow.up")
                        let imageUpArrowAttach = NSAttributedString(attachment: imageUpArrow)
                        let imageDownArrow = NSTextAttachment()
                        imageDownArrow.image = UIImage(systemName: "arrow.down")
                        let imageDownArrowAttach = NSAttributedString(attachment: imageDownArrow)
                        fullString.append(imageDownArrowAttach)
                        fullString.append(NSAttributedString(string: " \(String(Int((weatherData.currentTemperatureForecast!.temp_max))+1))°C "))
                        fullString.append(imageUpArrowAttach)
                        
                        self.labelTempMaxMin.attributedText = fullString
                        self.labelTempRessenti.text = "Ressenti : \(String(Int((weatherData.currentTemperatureForecast!.feels_like))+1))°C"
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        else{
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
    }

    static func getInstance(ville: CityEntity) -> HomeViewController {
        let vc = UIStoryboard (name: "Main", bundle:
                                nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.ville.append(ville)
        return vc
    }

}
