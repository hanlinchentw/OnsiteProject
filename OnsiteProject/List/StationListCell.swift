//
//  StationListCell.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import UIKit
import RxCocoa
import RxSwift

class StationListCell: UICollectionViewCell {
//MARK: - Properties
    @IBOutlet weak var maxWidthConstraint: NSLayoutConstraint!{
        didSet{
            self.maxWidthConstraint.isActive = true
        }
    }
    
    var maxWidth: CGFloat? = nil {
        didSet {
            guard let maxWidth = maxWidth else  { return }
            self.maxWidthConstraint.isActive = true
            self.maxWidthConstraint.constant = maxWidth
        }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var currentStateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var totalNumLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
//    @IBOutlet weak var walkingTimeLabel: UILabel!
    
    private var bag = DisposeBag()
//MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print("Awake from nib ...")
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
        
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.containerView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    func configureView(_ viewObject: StationViewObject) {
        self.nameTitle.text = viewObject.name
        self.currentStateLabel.text = viewObject.currentState
        self.addressLabel.text = viewObject.address
//        self.walkingTimeLabel.text = viewObject.walkingTime
        self.totalNumLabel.text = viewObject.totalNum
        let likeButtonImage: UIImage? = viewObject.isLiked ? UIImage(named: "icnHeart") : UIImage(named: "icnUnselectHeart")
        self.likeButton.setImage(likeButtonImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}
