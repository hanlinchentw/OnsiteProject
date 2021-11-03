//
//  StationMapViewController.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa

class StationMapViewController: UIViewController, AlertPresentation {
//MARK: - Properties
    var viewObject: [StationViewObject]?
    let viewModel = StationViewModel()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var relocateButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    private var directionCollection = [MKDirections]()
    var destination = BehaviorRelay<StationViewObject?>(value: nil)
    
    var dismissMethod: (()->())?
    let bag = DisposeBag()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        centerViewDependsOnUserLocation()
        updateAnnotationState()
        observeRelocateButton()
        observeRefreshButton()
        observeBackButton()
        observeDestinaion()
    }
    deinit {
        print("Map view deinit...")
    }
//MARK: - Observe
    private func observeDestinaion(){
        destination.subscribe { [weak self] event in
            guard let object = event.element else { return }
            guard let anno = self?.mapView.annotations.first(where: { $0.title == object?.name }) else { return }
            self?.mapView.selectAnnotation(anno, animated: true)
        }.disposed(by: bag)
    }
    private func observeRelocateButton(){
        relocateButton.rx.tap
            .bind { [weak self] _ in
                self?.centerViewDependsOnUserLocation()
            }.disposed(by: bag)
    }
    private func observeRefreshButton(){
        refreshButton.rx.tap
            .asObservable()
            .bind { [weak self] in
                guard let self = self else { return }
                self.get()
            }.disposed(by: bag)
    }
    private func observeBackButton(){
        backButton.rx.tap
            .asObservable()
            .bind { [weak self] in
                self?.dismiss(animated: true, completion:{
                    if let dismissMethod = self?.dismissMethod {
                        dismissMethod()
                    }
                })
            }.disposed(by: bag)
    }
    private func get(){
        viewModel.getAllStationsViewObject()
            .subscribe (onNext: { [weak self] object in
                self?.viewObject = object.cells.flatMap {$0}
                self?.updateAnnotationState()
                self?.checkIfLiked()
            }, onError: { error in
                if let error = error as? APIRequestError {
                    self.showApiRequestErrorAlert(error: error)
                }
                print(error.localizedDescription)
            }, onCompleted: {
                print("DEBUG: Completed")
            }).disposed(by: bag)
    }
    private func checkIfLiked(){
        viewModel.getFavoriteStation()
            .subscribe(onNext: { [weak self] names in
                print("DEBUG: Like \(names)")
                names.forEach { self?.updateLikeState(stationName: $0) }
            }, onError: { [weak self] error in
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                self?.showAlert(title: "Local data error", subTitle: "Sorry! Couldn't get favorite station",
                                firstAction: okAction)
                print(error.localizedDescription)
            }).disposed(by: bag)
    }
    private func updateLikeState(stationName: String){
        print("Update: ", stationName)
        guard let viewObject = self.viewObject else { return }
        for (index, item) in viewObject.enumerated() {
            if stationName == item.name {
                self.viewObject?[index].isLiked.toggle()
                self.updateAnnotationState()
            }
        }
    }
    private func add(_ stationName: String){
        viewModel.addFavoriteStation(add: stationName)
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
//MARK: - UI Method
    private func initView(){
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        NSLayoutConstraint.activate([
            self.relocateButton.widthAnchor.constraint(equalToConstant: 56),
            self.relocateButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        self.relocateButton.layer.cornerRadius = 56 / 2
        self.relocateButton.layer.borderWidth = 0.75
        self.relocateButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func updateAnnotationState() {
        guard let viewObject = viewObject, let mapView = mapView else { return }
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(self.mapView.overlays)
        var annos = [StationPointAnnotation]()
        viewObject.forEach { object in
            let annotation = StationPointAnnotation(viewObject: object)
            annotation.title = object.name
            annotation.coordinate = object.location
            annos.append(annotation)
        }
        mapView.addAnnotations(annos)
    }
    
    private func centerViewDependsOnUserLocation(){
        mapView.showsUserLocation = true
        guard let userLocation = LocationHandler.shared.locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    func getDirection(to destination: CLLocationCoordinate2D) {
        guard let userLocation = LocationHandler.shared.locationManager.location?.coordinate else { return }
        let request = makeDirectionRequest(from: userLocation, to: destination)
        let directions = MKDirections(request: request)
        resetDirections(withNew: directions)
        directions.calculate { [weak self] response, error in
            guard let response = response else {
                self?.showAlert(title: "Map error", subTitle: "Can't find direction",
                                firstAction: UIAlertAction(title: "OK", style: .cancel, handler: nil))
                return
            }
            guard let route = response.routes.first else { return }
            self?.mapView.addOverlay(route.polyline)
        }
    }
    private func makeDirectionRequest(from startLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> MKDirections.Request{
        let startLocationMark = MKPlacemark(coordinate: startLocation)
        let destinationMark = MKPlacemark(coordinate: destination)
        let request  = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocationMark)
        request.destination = MKMapItem(placemark: destinationMark)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        return request
    }
    func resetDirections(withNew directions: MKDirections){
        mapView.removeOverlays(mapView.overlays)
        directionCollection.append(directions)
        let _ = directionCollection.map { $0.cancel() }
    }
}

extension StationMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? StationPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            }
            
            annotationView?.annotation = annotation
            annotationView?.image = UIImage(named: "btnLocationUnselect")
            return annotationView
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }
        guard let annotation = view.annotation as? StationPointAnnotation else { return }
        let customCalloutView : StationListCell = .fromNib()
        customCalloutView.maxWidth = self.view.frame.width * 0.8
        customCalloutView.viewObject = annotation.viewObject
        customCalloutView.center = CGPoint(x: view.bounds.size.width / 2,
                                           y: customCalloutView.bounds.size.height*0.8)
        view.frame = customCalloutView.bounds
        
        view.addSubview(customCalloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        view.image = UIImage(named: "btnLocationSelected")
        getDirection(to: annotation.coordinate)
        
        customCalloutView.likeButton.rx.tap
            .subscribe(onNext: {  [weak self] _ in
                if annotation.viewObject.isLiked {
                    self?.delete(annotation.viewObject.name)
                }else {
                    self?.add(annotation.viewObject.name)
                }
            }).disposed(by: customCalloutView.bag)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = UIImage(named: "btnLocationUnselect")
        view.subviews.forEach { subview in
            if let subview = subview as? StationListCell {
                subview.removeFromSuperview()
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        return renderer
    }
}

extension MKAnnotationView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubviewToFront(self)
        }
        return hitView
    }
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}
