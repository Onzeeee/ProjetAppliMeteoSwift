//
//  ViewControllerHeureSuivantes.swift
//  AppliMeteo
//
//  Created by tplocal on 08/03/2023.
//

import UIKit

// Cette classe est utilisé dans la classe HomeViewController, elle n'est pas vraiment appelé ou instancié puisque la liaison est faite dans le storyboard
// via une segue crée grâce à un container
class ViewControllerHeureSuivantes: UIViewController, HomeViewControllerDelegateDeux {
    
    // Les deux fonction suivantes sont lié au protocol HomeViewControllerDelegateDeux qui permet le changement d'unité entre °C et °F
    func passageFrancais() {
        for subview in viewScroll.subviews{
            subview.removeFromSuperview()
        }
        if(villeActuelle != nil){
            Task{
                do{
                    let weatherData = try? await fetchWeatherData(context: leContexte, for: villeActuelle!, language: "fr")
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
    }
    
    func passageAnglais() {
        for subview in viewScroll.subviews{
            subview.removeFromSuperview()
        }
        if(villeActuelle != nil){
            Task{
                do{
                    let weatherData = try? await fetchWeatherData(context: leContexte, for: villeActuelle!, language: "an")
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
                            labelTemp.text = "\(Int(weatherData.sortedTemperatureForecast[index].temp))°F"
                            self.viewScroll.addSubview(labelHeure)
                            self.viewScroll.addSubview(imageIcon)
                            self.viewScroll.addSubview(labelTemp)
                        }
                    }
                }
            }

        }
    }
    

    var villeActuelle : CityEntity?
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var viewScroll: UIView!
    
    // Dans ce viewDidLoad nous récupérons les weatherData afin d'avoir par la suite toutes les heures suivantes et de les afficher
    // Leur affichage est lié à leur taille ou on multiplie leur place dans la liste et une taille prévu.
    override func viewDidLoad() {
        super.viewDidLoad()
        for subview in viewScroll.subviews{
            subview.removeFromSuperview()
        }
        if(villeActuelle != nil){
            Task{
                do{
                    let weatherData = try? await fetchWeatherData(context: leContexte, for: villeActuelle!, language: "fr")
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
    }
}
