//
//  ViewControllerImage.swift
//  AppliMeteo
//
//  Created by tplocal on 28/02/2023.
//

import UIKit

class ViewControllerImage: UIViewController {

    var imageViewAttribut : UIImageView?
    @IBOutlet weak var textPasImage: UILabel!
    var textLabel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textPasImage.text = textLabel
        if(imageViewAttribut == nil){
            
        }else{
            self.view.addSubview(imageViewAttribut!)
            imageViewAttribut?.frame = CGRect(x: 0, y: 0, width: 393, height: 253)
        }
        // Do any additional setup after loading the view.
    }
    
    static func getInstance(imageView: UIImageView) -> ViewControllerImage {
        let vc = UIStoryboard (name: "Main", bundle:
                                nil).instantiateViewController(withIdentifier: "ViewControllerImage") as! ViewControllerImage
        vc.imageViewAttribut = imageView
        return vc
    }
    
    static func getInstanceMessage(message : String) -> ViewControllerImage{
        let vc = UIStoryboard (name: "Main", bundle:
                                nil).instantiateViewController(withIdentifier: "ViewControllerImage") as! ViewControllerImage
        vc.textLabel = message
        return vc
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
