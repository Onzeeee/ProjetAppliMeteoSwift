//
//  ViewControllerDetailsVille.swift
//  AppliMeteo
//
//  Created by tplocal on 25/02/2023.
//

import UIKit
import MapKit

protocol ViewControllerDetailsVilleDelegate{
    func afficherImage(image: UIImageView)
}

class ViewControllerDetailsVille: UIViewController, MKMapViewDelegate, ViewControllerImagesDelegate{

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
    var delegateDetails : ViewControllerDetailsVilleDelegate?
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude), regionRadius: 100000)
        // Do any additional setup after loading the view.
    }
    
    func afficherImage(image: UIImageView) {
        image.frame = CGRect(x: 16, y: 211, width: 361, height: 528)
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        newView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.addSubview(newView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        image.isUserInteractionEnabled = true
        image.contentMode = .scaleAspectFit
        image.addGestureRecognizer(tapGesture)
        self.view.addSubview(image)
    }
    
    @objc func imageTapped(_ sender : UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        imageView.contentMode = .scaleToFill
        delegateDetails?.afficherImage(image: imageView)
        if let frontSubview = self.view.subviews.last {
            frontSubview.removeFromSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sndVC = segue.destination as! ViewControllerImages
        sndVC.ville = ville
        sndVC.delegateImage = self
        self.delegateDetails = sndVC
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

