//
//  CommentCell.swift
//  instaparse
//
//  Created by Oliver Thurn on 4/9/19.
//  Copyright © 2019 Oliver Thurn. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var unCommentLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
