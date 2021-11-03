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

class StationListViewController: UIViewController, AlertPresentation {
    //MARK: - Properties
    private let viewModel = StationViewModel()
    private var viewObject: AllStationsViewObject?
    private var mutableViewObject: AllStationsViewObject?
    private let filterModeObject = BehaviorRelay<Bool>(value: false)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapPageTransitionButton: UIButton!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
   
    private let bag = DisposeBag()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG:App folder: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        self.collectionView.isUserInteractionEnabled = false
        initView()
        askUserLocation()
        get()
        observeFilterButton()
        observeRefreshButton()
        setModeObserver()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToMapVC" {
            weak var controller = segue.destination as? StationMapViewController
            controller?.viewObject = self.viewObject?.cells.flatMap {$0}
            controller?.dismissMethod = {
                self.refreshData()
            }
            if let sender = sender as? StationViewObject {
                controller?.destination.accept(sender)
            }
        }
    }
    //MARK: - Observe
    private func get(){
        viewModel.getAllStationsViewObject()
            .subscribe (onNext: { [weak self] object in
                self?.viewObject = object
                self?.filterModeObject.accept(false)
                self?.checkIfLiked()
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
            }, onError: { error in
                if let error = error as? APIRequestError {
                    self.showApiRequestErrorAlert(error: error)
                }
                print(error.localizedDescription)
            }, onCompleted: {[weak self] in
                print("DEBUG: Completed")
                self?.collectionView.isUserInteractionEnabled = true
            }).disposed(by: bag)
    }
    private func checkIfLiked(){
        viewModel.getFavoriteStation()
            .subscribe(onNext: { [weak self] names in
                print("DEBUG: Like \(names)")
                guard let self = self,
                self.viewObject != nil,
                self.mutableViewObject != nil else { return}
                names.forEach {self.updateLikeState(in: &self.viewObject!, stationName: $0, updateRow: false) }
                names.forEach {self.updateLikeState(in: &self.mutableViewObject!, stationName: $0, updateRow: true) }
            }, onError: { error in
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                self.showAlert(title: "Local data error", subTitle: "Sorry! Couldn't get favorite station", firstAction: okAction)
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func observeRefreshButton(){
        refreshButton.rx.tap
            .asObservable()
            .bind(onNext: { [weak self] in
                self?.refreshData()
            }).disposed(by: bag)
    }
    private func observeFilterButton(){
        filterButton.rx.tap
            .asObservable()
            .bind (onNext: { [weak self] in
                self?.filterModeObject.accept(!(self?.filterModeObject.value ?? true))
            }).disposed(by: bag)
    }
    private func setModeObserver(){
        filterModeObject.asObservable()
            .subscribe( onNext:{ [weak self] isFilterMode in
                print("Mode switch")
                if isFilterMode {
                    self?.viewObject = self?.mutableViewObject
                    guard let viewObject = self?.viewObject else { return }
                    let allLikedCells = viewObject.cells.flatMap{ $0 }.filter{$0.isLiked }
                    let (keys, cells) = Array<Any>().groupStationByArea(stations: allLikedCells)
                    self?.mutableViewObject = AllStationsViewObject(keys: keys, cells: cells)
                }else{
                    self?.mutableViewObject = self?.viewObject
                }
                self?.collectionView.reloadData()
            }).disposed(by: bag)
    }
    private func add(_ stationName: String){
        viewModel.addFavoriteStation(add: stationName)
            .subscribe ( onNext: { [weak self] name in
                print("DEBUG: Add \(name)")
                guard let self = self,
                self.viewObject != nil,
                self.mutableViewObject != nil else { return}
                self.updateLikeState(in: &self.viewObject!, stationName: name, updateRow: false)
                self.updateLikeState(in: &self.mutableViewObject!, stationName: name, updateRow: true)
            },onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func delete(_ stationName: String){
        viewModel.deleteFavoriteStation(delete: stationName)
            .subscribe (onNext: { [weak self] name in
                print("DEBUG: Delete \(name)")
                guard let self = self,
                self.viewObject != nil,
                self.mutableViewObject != nil else { return}
                self.updateLikeState(in: &self.viewObject!, stationName: name, updateRow: false)
                self.updateLikeState(in: &self.mutableViewObject!, stationName: name, updateRow: true)
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func updateLikeState(in viewObject: inout AllStationsViewObject, stationName: String, updateRow: Bool){
        print("Update: ", stationName)
        for (section, sectionItem) in viewObject.cells.enumerated() {
            for (row, rowItem) in sectionItem.enumerated() {
                if stationName == rowItem.name {
                    viewObject.cells[section][row].isLiked.toggle()
                    if updateRow { self.collectionView.reloadData() }
                }
            }
        }
    }
    //MARK: - UI Method
    private func initView(){
        let headerNib = UINib(nibName: "ListHeaderView", bundle: nil)
        let listNib = UINib(nibName: "StationListCell", bundle: nil)
        self.collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.listHeaderIdentifier)
        self.collectionView.register(listNib, forCellWithReuseIdentifier: Constants.listCellIdentifier)
        
        self.mapPageTransitionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapPageTransitionButton.widthAnchor.constraint(equalToConstant: 72),
            self.mapPageTransitionButton.heightAnchor.constraint(equalToConstant: 72)
        ])
        self.mapPageTransitionButton.layer.cornerRadius = 72 / 2
        self.mapPageTransitionButton.layer.borderWidth = 0.75
        self.mapPageTransitionButton.layer.borderColor = UIColor.black.cgColor
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout ,
           let cv = collectionView {
            flowLayout.estimatedItemSize = CGSize(width: cv.frame.width*0.85, height: 150)
        }
    }
    private func askUserLocation(){
        LocationHandler.shared.enableLocationServices()
    }
    private func refreshData(){
        collectionView.isUserInteractionEnabled = false
        viewObject = nil
        mutableViewObject = nil
        get()
    }
}

extension StationListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mutableViewObject?.keys.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mutableViewObject?.cells[section].count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationListCell", for: indexPath)
            as! StationListCell
        cell.maxWidth = self.collectionView.bounds.width * 0.85
        if let cellObject = self.mutableViewObject?.cells[indexPath.section][indexPath.row] {
            cell.viewObject = cellObject
            cell.likeButton.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    if cellObject.isLiked {
                        self?.delete(cellObject.name)
                    }else {
                        self?.add(cellObject.name)
                    }
                }).disposed(by: cell.bag)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cellObject = self.mutableViewObject?.cells[indexPath.section][indexPath.row] {
            self.performSegue(withIdentifier:  "PushToMapVC", sender: cellObject)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.listHeaderIdentifier, for: indexPath) as! ListHeaderView
        let area = self.mutableViewObject?.keys[indexPath.section] ?? "Not found"
        header.configureTitle(area)
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 72)
    }
}
extension StationListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
