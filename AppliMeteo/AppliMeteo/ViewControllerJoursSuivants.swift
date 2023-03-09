//
//  ViewControllerHeureSuivantes.swift
//  AppliMeteo
//
//  Created by tplocal on 08/03/2023.
//

import UIKit

class ViewControllerJoursSuivants: UIViewController {

    var villeActuelle : CityEntity?
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var viewScroll: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(villeActuelle != nil){
            Task{
                do{
                    let weatherdata = try await fetchWeatherData(context: leContexte, for: villeActuelle!)
                    guard let city = weatherdata.city else{
                        fatalError("Error: city is nil")
                        return
                    }
                    self.onWeatherDataReceived(weatherData: weatherdata)
                }
                catch{
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        else{
            print("Pas de ville")
        }
        // Do any additional setup after loading the view.
    }

    func onWeatherDataReceived(weatherData : WeatherData){
        DispatchQueue.main.async {
            for index in 0..<weatherData.sortedTemperatureForecastDaily.count{
                let labelHeure = UILabel(frame: CGRect(x: 10+(100*index), y: 0, width: 80, height: 50))
                labelHeure.textAlignment = .center
                labelHeure.font = .systemFont(ofSize: 25)
                labelHeure.text = "\(intToDate(unixTime: weatherData.sortedTemperatureForecastDaily[index].dt))"
                let imageIcon = UIImageView(frame: CGRect(x: 5+(100*index), y: 58, width: 90, height: 90))
                imageIcon.image = UIImage(named: "\(weatherData.sortedTemperatureForecastDaily[index].weather_icon!).png")
                let labelTemp = UILabel(frame: CGRect(x: 10+(100*index), y: 156, width: 80, height: 40))
                labelTemp.textAlignment = .center
                labelTemp.font = .systemFont(ofSize: 20)
                labelTemp.text = "\(Int(weatherData.sortedTemperatureForecastDaily[index].temp_day))°C"
                self.viewScroll.addSubview(labelHeure)
                self.viewScroll.addSubview(imageIcon)
                self.viewScroll.addSubview(labelTemp)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
