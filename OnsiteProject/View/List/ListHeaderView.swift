//
//  ListHeaderView.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/31.
//

import UIKit

class ListHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureTitle(_ area: String) {
        titleLabel.text = area
    }
}
