//
//  ViewControllerImages.swift
//  AppliMeteo
//
//  Created by tplocal on 17/03/2023.
//

import UIKit

protocol ViewControllerImagesDelegate : AnyObject{
    func afficherImage(image: UIImageView)
}

class ViewControllerImages: UIViewController {
    

    @IBOutlet weak var viewImages: UIView!
    var ville : String = ""
    weak var delegate : ViewControllerImagesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findPhotos(query: ville) { result in
            switch result{
            case .success(let photos):
                DispatchQueue.main.async { [self] in
                    if(photos.count == 0){
                        for i in 0..<10{
                            let label = UILabel(frame: CGRect(x: 45+(196*i), y: 135, width: 106, height: 21))
                            label.text = "Pas d'images"
                            viewImages.addSubview(label)
                        }
                    }
                    else{
                        var index = 0
                        for photo in photos{
                            let image = UIImageView()
                            let url = URL(string: photo)
                            image.load(url: url!)
                            image.tag = index
                            image.contentMode = .scaleToFill
                            image.frame = CGRect(x: index*196, y: 0, width: 196, height: 285)
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
    
    @objc func imageTapped(_ sender : UITapGestureRecognizer){
        let imageView = sender.view as! UIImageView
        delegate?.afficherImage(image: imageView)
    }

    func getImageViewWithTag(tag: Int) -> UIImageView? {
        for subview in self.view.subviews {
            if let imageView = subview as? UIImageView, imageView.tag == tag {
                return imageView
            }
        }
        return nil
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
