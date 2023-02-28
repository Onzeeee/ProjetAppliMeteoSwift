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
    
    var listeImage : [UIImageView] = []
    var longitude : Double = Double()
    var latitude : Double = Double()
    var ville : String = ""
    var nbrTimeCanChangeImage : Int = 0
    var nbrTimeChanged : Int = 0
    
    let leContexte = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Longitude : \(longitude) et Latitude : \(latitude)")
        mapVille.centerToLocation(CLLocation(latitude: latitude, longitude: longitude))
        print(ville)
        findPhotos(query: ville) { result in
            switch result{
            case .success(let photos):
                DispatchQueue.main.async {
                    for photo in photos{
                        let image = UIImageView()
                        let url = URL(string: photo)
                        image.load(url: url!)
                        self.listeImage.append(image)
                    }
                }
                break
            case .failure(let error):
                print(error)
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

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 100000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
