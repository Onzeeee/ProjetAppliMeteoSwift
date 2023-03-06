//
//  ViewControllerDetailsVille.swift
//  AppliMeteo
//
//  Created by tplocal on 25/02/2023.
//

import UIKit
import MapKit

class ViewControllerDetailsVille: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapVille: MKMapView!
    @IBOutlet weak var verticalSlider: UISlider!{
        didSet{
            verticalSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        }
    }
    
    var longitude : Double = Double()
    var latitude : Double = Double()
    var ville : String = ""
    var nbrTimeCanChangeImage : Int = 0
    var nbrTimeChanged : Int = 0
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude), regionRadius: 100000)
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sndVC = segue.destination as! PageControllerImage
        sndVC.ville = ville
        navigationItem.title = ville
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude), regionRadius: CLLocationDistance(verticalSlider.value))
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
        regionRadius: CLLocationDistance
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
