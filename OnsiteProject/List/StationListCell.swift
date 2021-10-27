//
//  StationListCell.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import UIKit

class StationListCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }
//MARK: - UI Method
    private func initView(){
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.2
        self.containerView.layer.cornerRadius = 12
        self.containerView.clipsToBounds = true
    }
}
