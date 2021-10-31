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
    private let viewModel = StationListViewModel()
    var viewObject: StationViewObject? { didSet{ configureView(self.viewObject) } }
    
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
        observeLikeButton()
    }
    func observeLikeButton(){
        likeButton.rx.tap
            .asObservable()
            .bind(onNext: {  [weak self] _ in
                guard let viewObject = self?.viewObject else { return }
                if viewObject.isLiked {
                    self?.delete(viewObject.name)
                }else {
                    self?.add(viewObject.name)
                }
            }).disposed(by: bag)
    }
    private func add(_ stationName: String){
        viewModel.addStationIntoFavorite(add: stationName)
            .subscribe ( onNext: { [weak self] name in
                print("DEBUG: Add \(name)")
                self?.updateLikeState(stationName: name)
            },onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func delete(_ stationName: String){
        viewModel.deleteFavoriteStation(delete: stationName)
            .subscribe (onNext: { [weak self] name in
                print("DEBUG: Delete \(name)")
                self?.updateLikeState(stationName: name)
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
        
    }
    private func updateLikeState(stationName: String){
        print("Update: ", stationName)
        guard let viewObject = self.viewObject else { return }
        if stationName == viewObject.name {
            self.viewObject?.isLiked.toggle()
        }
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
    private func configureView(_ viewObject: StationViewObject?) {
        guard let viewObject = viewObject else { return }
        self.nameTitle.text = viewObject.name
        self.currentStateLabel.text = viewObject.currentState
        self.addressLabel.text = viewObject.address
//        self.walkingTimeLabel.text = viewObject.walkingTime
        self.totalNumLabel.text = viewObject.totalNum
        let likeButtonImage: UIImage? = viewObject.isLiked ? UIImage(named: "icnHeart") : UIImage(named: "icnUnselectHeart")
        self.likeButton.setImage(likeButtonImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
}
