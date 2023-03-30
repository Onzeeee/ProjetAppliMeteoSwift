//
//  ViewControllerImages.swift
//  AppliMeteo
//
//  Created by tplocal on 17/03/2023.
//

import UIKit

// Ce protocol permet la fonctionnalité d'afficher une image en gros sur la page avec la carte.
protocol ViewControllerImagesDelegate{
    func afficherImage(image: UIImageView)
}

// Cette classe est lié à toutes photos qui s'affiche sur la page détails.
class ViewControllerImages: UIViewController, ViewControllerDetailsVilleDelegate {

    @IBOutlet weak var viewImages: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var ville : String = ""
    var delegateImage : ViewControllerImagesDelegate?
    
    // Dans ce viewDidLoad on utilise la fonction va chercher toutes les photos via l'api que nous utilisons
    override func viewDidLoad() {
        super.viewDidLoad()
        findPhotos(query: ville) { result in
            switch result{
            case .success(let photos):
                DispatchQueue.main.async { [self] in
                    if(photos.count == 0){
                        let label = UILabel(frame: CGRect(x: 81, y: 101, width: 234, height: 90))
                        label.font = .systemFont(ofSize: 30.0)
                        label.text = "Pas d'images"
                        label.textAlignment = .center
                        scrollView.isScrollEnabled = false
                        viewImages.addSubview(label)
                    }
                    else{
                        var index = 0
                        for photo in photos{
                            let image = UIImageView()
                            let url = URL(string: photo)
                            image.load(url: url!)
                            image.tag = index
                            image.contentMode = .scaleToFill
                            image.frame = CGRect(x: index*196, y: 0, width: 196, height: 293)
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                            image.isUserInteractionEnabled = true
                            image.addGestureRecognizer(tapGesture)
                            viewImages.addSubview(image)
                            index += 1
                            if(index == 10){
                                break
                            }
                        }
                        if(index < 10){
                            for i in index..<10{
                                let label = UILabel(frame: CGRect(x: 45+(196*i), y: 135, width: 106, height: 21))
                                label.text = "Plus d'images"
                                viewImages.addSubview(label)
                            }
                        }
                    }
                }
                break
            case .failure(let error):
                print(error)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    // Cette fonction intervient lorsque l'on clique sur une image
    @objc func imageTapped(_ sender : UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        delegateImage?.afficherImage(image: imageView)
    }
    
    // Cette fonction intervient lorsqu'on réappuie sur l'image, c'est une fonction venant du protocol ViewControllerDetailsVilleDelegate
    func afficherImage(image: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tapGesture)
        image.frame = CGRect(x: image.tag*196, y: 0, width: 196, height: 293)
        viewImages.addSubview(image)
    }

}

// Cette extension est la pour permettre le téléchargement des photos via un url
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
