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
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var windDir: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var iconDirVent: UIImageView!
    
    
    var ville : [CityEntity] = []
    var pageActuelle : Int = 0;
    var joursSuivants : [TemperatureForecastDaily] = []
    var tempMaxJoursSuivants : Int?
    var tempMinJoursSuivants : Int?
    var directionVent : [String:[Range<Double>]] = ["N":[0..<22.5],"NE":[22.5..<67.5],"E":[67.5..<112.5],"SE":[112.5..<157.5],"S":[157.5..<202.5],"SO":[202.5..<247.5],"O":[247.5..<292.5],"NO":[292.5..<337.5]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewJoursSuivants.isScrollEnabled = false
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
                        print(weatherData)
                        self.chargerLesDonneesVille(weatherData: weatherData)
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
        if(weatherData.city == nil){
            print("Error: city is nil : \(weatherData.city) for city \(ville[0].name) (not a probem in this case since we have the city entity, but something with the model should be wrong)")
        }
        let ville = ville[0]
        self.title = ville.name
        self.imageDescriptionTemps.image = UIImage(named: "\(weatherData.currentTemperatureForecast!.icon!).png")
        self.labelTemp.text = "\(String(Int(weatherData.currentTemperatureForecast!.temp)+1))°C"
        let fullString = NSMutableAttributedString(string : "\(String(Int((weatherData.sortedTemperatureForecastDaily[0].temp_min))))°C ")
        let imageUpArrow = NSTextAttachment()
        imageUpArrow.image = UIImage(systemName: "arrow.up")
        let imageUpArrowAttach = NSAttributedString(attachment: imageUpArrow)
        let imageDownArrow = NSTextAttachment()
        imageDownArrow.image = UIImage(systemName: "arrow.down")
        let imageDownArrowAttach = NSAttributedString(attachment: imageDownArrow)
        fullString.append(imageDownArrowAttach)
        fullString.append(NSAttributedString(string: " \(String(Int((weatherData.sortedTemperatureForecastDaily[0].temp_max))))°C "))
        fullString.append(imageUpArrowAttach)
        self.labelTempMaxMin.attributedText = fullString
        self.labelTempRessenti.text = "Ressenti : \(String(Int((weatherData.currentTemperatureForecast!.feels_like))+1))°C"
        let radians = CGFloat(weatherData.currentTemperatureForecast!.windDeg) * CGFloat.pi / 180.0
        self.iconDirVent.transform = CGAffineTransform(rotationAngle: radians)
        var directionString = ""
        for (cle, plage) in self.directionVent {
            for intervalle in plage {
                if intervalle.contains(Double(weatherData.currentTemperatureForecast!.windDeg)) {
                    directionString = cle
                    break
                }
            }
        }
        if(Double(weatherData.currentTemperatureForecast!.windDeg)>337.5){
            directionString = "N"
        }
        self.windDir.text = directionString
        self.humidity.text = "\(String(weatherData.currentTemperatureForecast!.humidityLevel))%"
        let vitesseKmH = Int(weatherData.currentTemperatureForecast!.windSpeed*3.6)
        self.windSpeed.text = "\(vitesseKmH) km/h"
        self.pressure.text = "\(String(weatherData.currentTemperatureForecast!.pressure))hPa"
        self.joursSuivants = weatherData.sortedTemperatureForecastDaily
        self.tempMaxJoursSuivants = Int(self.joursSuivants[0].temp_max)
        self.tempMinJoursSuivants = Int(self.joursSuivants[0].temp_min)
        for days in 1..<14{
            if(Int(self.joursSuivants[days].temp_min) < self.tempMinJoursSuivants!){
                self.tempMinJoursSuivants = Int(self.joursSuivants[days].temp_min)
            }
            if(Int(self.joursSuivants[days].temp_max) > self.tempMaxJoursSuivants!){
                self.tempMaxJoursSuivants = Int(self.joursSuivants[days].temp_max)
            }
        }
        self.tableViewJoursSuivants.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "heuresSuivantes"){
            let sndVC = segue.destination as! ViewControllerHeureSuivantes
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row+1
        let layerColor = CALayer()
        let layerFond = CALayer()
        
        let tailleparDegre = 179 / (tempMaxJoursSuivants! - tempMinJoursSuivants!)
        
        var xColor = 167
        var widthColor = 179
        if(Int(joursSuivants[index].temp_min) == tempMinJoursSuivants){}
        else{
            let tailleDiff = Int(joursSuivants[index].temp_min) - tempMinJoursSuivants!
            xColor = xColor + (tailleDiff*tailleparDegre)
            widthColor = widthColor - (tailleDiff*tailleparDegre)
        }
        if(Int(joursSuivants[index].temp_max) == tempMaxJoursSuivants){}
        else{
            let tailleDiff = tempMaxJoursSuivants! - Int(joursSuivants[index].temp_max)
            widthColor = widthColor - (tailleDiff*tailleparDegre)
        }
        
        layerColor.frame = CGRect(x: xColor, y: 25, width: widthColor, height: 7)
        layerColor.backgroundColor = CGColor(red: 0.45, green: 0.7, blue: 1, alpha: 1)
        layerColor.cornerRadius = 3
        
        
        layerFond.frame = CGRect(x: 167, y: 25, width: 179, height: 7)
        layerFond.backgroundColor = CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        layerFond.cornerRadius = 3
        let cell = tableViewJoursSuivants.dequeueReusableCell(withIdentifier: "maCellule", for: indexPath) as! TableViewCellJoursSuivants
        cell.layer.addSublayer(layerFond)
        cell.layer.addSublayer(layerColor)
        cell.dateJour.text = intToDate(unixTime: joursSuivants[index].dt).components(separatedBy: " ")[0]
        cell.tempMin.text = "\(String(Int(joursSuivants[index].temp_min)))°C"
        cell.tempMax.text = "\(String(Int(joursSuivants[index].temp_max)))°C"
        cell.imagePicto.image = UIImage(named: "\(joursSuivants[index].weather_icon!).png")
        return cell
    }

}
