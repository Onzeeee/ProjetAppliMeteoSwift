//
//  ViewControllerDetailsVille.swift
//  AppliMeteo
//
//  Created by tplocal on 25/02/2023.
//

import UIKit
import MapKit

class ViewControllerDetailsVille: UIViewController{

    @IBOutlet weak var mapVille: MKMapView!
    
    var longitude : Double = Double()
    var latitude : Double = Double()
    var ville : String = ""
    var nbrTimeCanChangeImage : Int = 0
    var nbrTimeChanged : Int = 0
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude))
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sndVC = segue.destination as! PageControllerImage
        sndVC.ville = ville
        navigationItem.title = ville
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

private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 100000
    ) {
        print("Coordonne de la position : \(location.coordinate.longitude) \(location.coordinate.latitude)")
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
