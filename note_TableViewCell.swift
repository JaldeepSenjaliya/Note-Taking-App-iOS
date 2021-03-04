//
//  note_TableViewCell.swift
//  Notes_Application_Project
//
//  Created by user175465 on 6/23/20.
//  Copyright © 2020 user175465. All rights reserved.
//

import UIKit

class note_TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
