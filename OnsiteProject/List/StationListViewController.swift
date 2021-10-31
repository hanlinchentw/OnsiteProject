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
    private var mutableViewObject: AllStationsViewObject?
   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapPageTransitionButton: UIButton!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    private let filterModeObject = BehaviorRelay<Bool>(value: false)
    private let bag = DisposeBag()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG:App folder: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        initView()
        get()
        askUserLocation()
        observeFilterButton()
        observeRefreshButton()
        setModeObserver()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToMapVC" {
            weak var controller = segue.destination as? StationMapViewController
            controller?.viewObject = self.viewObject?.cells.flatMap {$0}
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
                self?.filterModeObject.accept(false)
                self?.checkIfLiked()
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
            }, onError: { error in
                #warning("get station data error handling")
                print(error.localizedDescription)
            }, onCompleted: {
                print("DEBUG: Completed")
            }).disposed(by: bag)
    }
    private func checkIfLiked(){
        viewModel.getFavoriteStation()
            .subscribe(onNext: { [weak self] names in
                print("DEBUG: Like \(names)")
                names.forEach {self?.updateLikeState(stationName: $0)}
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func updateLikeState(stationName: String){
        print("Update: ", stationName)
        guard let viewObject = self.viewObject else { return }
        for (section, sectionItem) in viewObject.cells.enumerated() {
            for (row, item) in sectionItem.enumerated() {
                if stationName == item.name {
                    self.viewObject?.cells[section][row].isLiked.toggle()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    private func observeRefreshButton(){
        refreshButton.rx.tap
            .asObservable()
            .bind(onNext: { [weak self] in
                self?.viewObject = nil
                self?.mutableViewObject = nil
                self?.get()
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
                guard let viewObject = self?.viewObject else { return }
                if isFilterMode {
                    let cells = viewObject.cells
                    var allCells = cells.flatMap{ $0 }
                    allCells = allCells.filter { $0.isLiked }
                    let grouping = Dictionary(grouping: allCells) { $0.area }
                    let areas = Array(grouping.keys)
                    let newCells = Array(grouping.values)
                    self?.mutableViewObject = AllStationsViewObject(keys: areas, cells: newCells)
                }else{
                    self?.mutableViewObject = viewObject
                }
                self?.collectionView.reloadData()
            }).disposed(by: bag)
    }
    //MARK: - UI Method
    private func initView(){
        let headerNib = UINib(nibName: "ListHeaderView", bundle: nil)
        let listNib = UINib(nibName: "StationListCell", bundle: nil)
        self.collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.listHeaderIdentifier)
        self.collectionView.register(listNib, forCellWithReuseIdentifier: Constants.listCellIdentifier)
        
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mutableViewObject?.keys.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mutableViewObject?.cells[section].count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationListCell", for: indexPath)
        as! StationListCell
        cell.maxWidth = self.collectionView.bounds.width * 0.9
        if let cellObject = self.mutableViewObject?.cells[indexPath.section][indexPath.row] {
            cell.viewObject = cellObject
            
            let tap = UITapGestureRecognizer(target: self, action: nil)
            cell.addGestureRecognizer(tap)
            tap.rx.event.bind { [weak self] _  in
                self?.performSegue(withIdentifier:  "PushToMapVC", sender: cellObject)
            }.disposed(by: bag)
        }
        return cell
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
