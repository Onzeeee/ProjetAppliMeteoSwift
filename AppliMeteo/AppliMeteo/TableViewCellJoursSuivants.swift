//
//  TableViewCellJoursSuivants.swift
//  AppliMeteo
//
//  Created by tplocal on 15/03/2023.
//

import UIKit

class TableViewCellJoursSuivants: UITableViewCell {

    @IBOutlet weak var dateJour: UILabel!
    @IBOutlet weak var tempJour: UILabel!
    @IBOutlet weak var minMaxJour: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
