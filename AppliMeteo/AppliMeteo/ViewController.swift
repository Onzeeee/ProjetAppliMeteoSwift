//
//  ViewController.swift
//  AppliMeteo
//
//  Created by tplocal on 22/02/2023.
//

import UIKit

class HomeViewController: UIViewController {
    
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
        if(ville.count != 0){
            fetchWeatherData(context: leContexte, for: ville[0]) { result in
                switch(result){
                case .success(let weatherData):
                    self.chargerLesDonneesVille(weatherData: weatherData)
                case .failure:
                    break
                }
            }
        }
        else{
            print("No city selected")
            self.title = "No city selected"
        }

//        afficherFavori(ville: ville[0])
        // Do any additional setup after loading the view.
    }
    
    func chargerLesDonneesVille(weatherData : WeatherData){
        DispatchQueue.main.async{
            let ville = weatherData.city!;
            self.title = ville.name
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
            let icon = weatherData.currentTemperatureForecast?.icon!
            let premiereLettre = icon![icon!.index((icon!.startIndex), offsetBy: 0)]
            let deuxiemeLettre = icon![icon!.index((icon!.startIndex), offsetBy: 1)]
            self.imageDeFond.image = UIImage(named: "\(String(Int(String(premiereLettre))!))\(String(Int(String(deuxiemeLettre))!)).jpg")
            self.imageDeFond.contentMode = .scaleAspectFill
            self.labelTempMaxMin.attributedText = fullString
            self.labelTempRessenti.text = "Ressenti : \(String(Int((weatherData.currentTemperatureForecast!.feels_like))+1))°C"
        }
    }

    static func getInstance(ville: CityEntity) -> HomeViewController {
        let vc = UIStoryboard (name: "Main", bundle:
                                nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        vc.ville.append(ville)
        return vc
    }

    static func getInstanceNil() -> HomeViewController {
        let vc = UIStoryboard (name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return vc
    }

}
