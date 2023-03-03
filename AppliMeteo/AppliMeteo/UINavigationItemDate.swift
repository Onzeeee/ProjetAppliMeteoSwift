//
// Created by Pierre Zachary on 03/03/2023.
//

import Foundation
import UIKit

class UINavigationItemDate : UINavigationItem {
    required init?(coder: NSCoder) {
        super.init(title: "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let button = UIBarButtonItem(title: dateString.capitalized, style: .plain, target: nil, action: nil)
        // set the button color to gray
        button.tintColor = .darkGray
        // set the button to disable
        button.isEnabled = false
        self.leftBarButtonItem = button
    }
}
