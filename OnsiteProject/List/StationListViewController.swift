//
//  StationListCollectionViewController.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

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
        print("DEBUG:App folder: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        initView()
        get()
        askUserLocation()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToMapVC" {
            weak var controller = segue.destination as? StationMapViewController
            controller?.viewObject = self.viewObject
            if let sender = sender as? StationViewObject {
                controller?.destination.accept(sender)
            }
        }
    }
    //MARK: - Observe
    private func get(){
        viewModel.createStationsViewObject()
            .subscribe (onNext: { [weak self] object in
                self?.viewObject = object
                self?.checkIfLiked()
                self?.collectionView.reloadData()
            }, onError: { error in
                #warning("get station data error handling")
                print(error.localizedDescription)
            }, onCompleted: {
                print("DEBUG: Completed")
            }).disposed(by: bag)
    }
    
    private func add(_ stationName: String){
        viewModel.addStationIntoFavorite(add: stationName)
            .subscribe ( onNext: { name in
                print("DEBUG: Add \(name)")
            },onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    
    private func checkIfLiked(){
        viewModel.getFavoriteStation()
            .subscribe(onNext: { [weak self] names in
                print("DEBUG: Like \(names)")
                guard let viewObject = self?.viewObject else { return }
                for (index, item) in viewObject.cells.enumerated() {
                    if names.contains(item.name) {
                        self?.viewObject?.cells[index].isLiked = true
                    }
                }
                self?.collectionView.reloadData()
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func delete(_ stationName: String){
        viewModel.deleteFavoriteStation(delete: stationName)
            .subscribe (onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)

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
        cell.maxWidth = self.collectionView.bounds.width * 0.9
        if let cellObject = self.viewObject?.cells[indexPath.row] {
            cell.configureView(cellObject)
            let tap = UITapGestureRecognizer(target: self, action: nil)
            cell.addGestureRecognizer(tap)
            tap.rx.event.bind { [weak self] _  in
                self?.performSegue(withIdentifier:  "PushToMapVC", sender: cellObject)
            }.disposed(by: bag)
            
            cell.likeButton.rx.tap
                .asObservable()
                .bind{ [weak self] _ in
                    if cellObject.isLiked {
                        self?.delete(cellObject.name)
                    }else {
                        self?.add(cellObject.name)
                    }
                }.disposed(by: bag)
        }
        return cell
    }
}
extension StationListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
