//
//  TableViewCellJoursSuivants.swift
//  AppliMeteo
//
//  Created by tplocal on 15/03/2023.
//

import UIKit

// Cette permet l'implémentation de la tableview qui affiche les jours suivants afin de les afficher comme on le souhaite via une custom cell
class TableViewCellJoursSuivants: UITableViewCell {

    @IBOutlet weak var dateJour: UILabel!
    @IBOutlet weak var tempMin: UILabel!
    @IBOutlet weak var tempMax: UILabel!
    @IBOutlet weak var imagePicto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
