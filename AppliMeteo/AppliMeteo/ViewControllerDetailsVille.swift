//
//  ViewControllerDetailsVille.swift
//  AppliMeteo
//
//  Created by tplocal on 25/02/2023.
//

import UIKit
import MapKit

// Ce protocol est créé afin d'intéragir avec la fonctionnalité de la photo qui s'aggrandit
protocol ViewControllerDetailsVilleDelegate{
    func afficherImage(image: UIImageView)
}

// Cette classe est lié à la page détail qui apparait lorsqu'on clique sur plus d'informations sur une ville dans la liste des favoris dans le menu
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
    
    // Dans ce viewDidLoad on met juste la carte centré sur la choisie.
    override func viewDidLoad() {
        super.viewDidLoad()
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude), regionRadius: 100000)
        // Do any additional setup after loading the view.
    }
    
    // Cette fonction est lié au protocol ViewControllerImagesDelegate qui permet d'afficher l'image en grand.
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
    
    // Cette fonction permet de reduire l'image lorsque l'on reclique dessus
    @objc func imageTapped(_ sender : UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        imageView.contentMode = .scaleToFill
        delegateDetails?.afficherImage(image: imageView)
        if let frontSubview = self.view.subviews.last {
            frontSubview.removeFromSuperview()
        }
    }
    
    // Ici nous envoyons la ville actuelle à la classe ViewControllerImages afin de trouver les photos en rapport, et on ajoute aussi le delegate qui permet
    // de lié cette classe avec le ViewControllerImages.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sndVC = segue.destination as! ViewControllerImages
        sndVC.ville = ville
        sndVC.delegateImage = self
        self.delegateDetails = sndVC
    }
    
    // Cette fonction permet au slide sur la droite de la carte d'agir sur la carte afin de zoomer ou dezoomer
    @IBAction func sliderChanged(_ sender: Any) {
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude), regionRadius: CLLocationDistance(verticalSlider.value))
    }
}

// Cette extension permet de faire centrer la map sur une longitude et une latitude donnée
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

