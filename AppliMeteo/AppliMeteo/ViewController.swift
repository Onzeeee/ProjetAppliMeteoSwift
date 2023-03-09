//
//  ViewController.swift
//  AppliMeteo
//
//  Created by tplocal on 22/02/2023.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageDescriptionTemps: UIImageView!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var labelTempMaxMin: UILabel!
    @IBOutlet weak var labelTempRessenti: UILabel!
    @IBOutlet weak var tableViewJoursSuivants: UITableView!

    
    var ville : [CityEntity] = []
    var pageActuelle : Int = 0;
    var joursSuivants : [TemperatureForecastDaily] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Loading..."
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not access app delegate")
        }
        let leContexte = appDelegate.persistentContainer.viewContext
        if(ville.count != 0){
            let cityentity = self.ville[0]
            Task{
                do{
                    let weatherData = try await fetchWeatherData(context: leContexte, for: cityentity)
                    print("Weather data loaded for \(cityentity.name)")
                    DispatchQueue.main.async{
                        self.chargerLesDonneesVille(weatherData: weatherData)
                        self.joursSuivants = weatherData.sortedTemperatureForecastDaily
                        self.tableViewJoursSuivants.reloadData()
                    }
                }
                catch (let error){
                    print("Error: \(error)")
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
        let ville = ville[0];
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
        self.labelTempMaxMin.attributedText = fullString
        self.labelTempRessenti.text = "Ressenti : \(String(Int((weatherData.currentTemperatureForecast!.feels_like))+1))°C"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "heuresSuivantes"){
            let sndVC = segue.destination as! ViewControllerHeureSuivantes
            if(ville.count == 0){}
            else{
                sndVC.villeActuelle = ville[0]
            }
        }
        else if(segue.identifier == "joursSuivants"){
            let sndVC = segue.destination as! ViewControllerJoursSuivants
            if(ville.count == 0){}
            else{
                sndVC.villeActuelle = ville[0]
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joursSuivants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewJoursSuivants.dequeueReusableCell(withIdentifier: "maCellule", for: indexPath)
        cell.textLabel!.text = intToDate(unixTime: joursSuivants[indexPath.row].dt).components(separatedBy: " ")[0]
        cell.detailTextLabel!.text = "\(String(Int(joursSuivants[indexPath.row].temp_day)))°C"
        return cell
    }

}
