//
//  StationListCollectionViewController.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import UIKit
import RxSwift
import RxCocoa

class StationListViewController: UIViewController {
    //MARK: - Properties
    private let viewModel = StationListViewModel()
    private var viewObject: AllStationsViewObject?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapPageTransitionButton: UIButton!
    
    private let bag = DisposeBag()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        get()
        askUserLocation()
    }
    //MARK: - Observe
    private func get(){
        viewModel.getStationInfo()
            .subscribe { [weak self] object in
                self?.viewObject = object
                self?.collectionView.reloadData()
            } onFailure: { error in
                print(error.localizedDescription)
            }.disposed(by: bag)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? StationMapViewController ,
           segue.identifier == "PushToMapVC" {
            controller.viewObject = self.viewObject
        }
    }
    //MARK: - UI Method
    private func initView(){
        let nib = UINib(nibName: "StationListCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: Constants.listCellIdentifier)
        self.collectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        self.mapPageTransitionButton.translatesAutoresizingMaskIntoConstraints = false
        let mapButtonWidthAndHeight = self.view.frame.width*0.15
        NSLayoutConstraint.activate([
            self.mapPageTransitionButton.widthAnchor.constraint(equalToConstant: mapButtonWidthAndHeight),
            self.mapPageTransitionButton.heightAnchor.constraint(equalToConstant: mapButtonWidthAndHeight)
        ])
        self.mapPageTransitionButton.layer.cornerRadius = mapButtonWidthAndHeight / 2
        self.mapPageTransitionButton.layer.borderWidth = 0.75
        self.mapPageTransitionButton.layer.borderColor = UIColor.black.cgColor
    }
    private func askUserLocation(){
        LocationHandler.shared.enableLocationServices()
    }
}

extension StationListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewObject?.cells.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationListCell", for: indexPath)
        as! StationListCell
        cell.maxWidth = self.collectionView.bounds.width * 0.65
        if let cellObject = self.viewObject?.cells[indexPath.row] {
            cell.configureView(cellObject)
        }
        return cell
    }
}
extension StationListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
