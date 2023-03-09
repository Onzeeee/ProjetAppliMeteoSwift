//
//  ViewControllerHeureSuivantes.swift
//  AppliMeteo
//
//  Created by tplocal on 08/03/2023.
//

import UIKit

class ViewControllerHeureSuivantes: UIViewController {

    var villeActuelle : CityEntity?
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var viewScroll: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(villeActuelle != nil){
            Task{
                do{
                    let weatherData = try? await fetchWeatherData(context: leContexte, for: villeActuelle!)
                    guard let weatherData else {return}
                    DispatchQueue.main.async {
                        for index in 0..<weatherData.sortedTemperatureForecast.count{
                            let labelHeure = UILabel(frame: CGRect(x: 10 + (100 * index), y: 0, width: 80, height: 50))
                            labelHeure.textAlignment = .center
                            labelHeure.font = .systemFont(ofSize: 25)
                            labelHeure.text = "\(intToDate(unixTime: weatherData.sortedTemperatureForecast[index].dt).components(separatedBy: " ")[1].components(separatedBy: ":")[0])h"
                            let imageIcon = UIImageView(frame: CGRect(x: 5 + (100 * index), y: 58, width: 90, height: 90))
                            imageIcon.image = UIImage(named: "\(weatherData.sortedTemperatureForecast[index].icon!).png")
                            let labelTemp = UILabel(frame: CGRect(x: 10 + (100 * index), y: 156, width: 80, height: 40))
                            labelTemp.textAlignment = .center
                            labelTemp.font = .systemFont(ofSize: 20)
                            labelTemp.text = "\(Int(weatherData.sortedTemperatureForecast[index].temp))°C"
                            self.viewScroll.addSubview(labelHeure)
                            self.viewScroll.addSubview(imageIcon)
                            self.viewScroll.addSubview(labelTemp)
                        }
                    }
                }
            }

        }
        // Do any additional setup after loading the view.
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
