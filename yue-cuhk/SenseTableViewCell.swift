//
//  SenseTableViewCell.swift
//  yue-cuhk
//
//  Created by Pak on 2016-11-18.
//  Copyright © 2016 pakwlau.com. All rights reserved.
//

import UIKit


class SenseTableViewCell: UITableViewCell {

    @IBOutlet weak var labelHomophone: UILabel!
    @IBOutlet weak var labelSyllabel: UILabel!
    @IBOutlet weak var labelExplanation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        //appearance
        let view = UIView()
        view.backgroundColor = Constants.selectedColor
        selectedBackgroundView = view
    }
    
    
}
