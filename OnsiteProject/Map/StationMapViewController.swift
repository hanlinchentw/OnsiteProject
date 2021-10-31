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

class StationMapViewController: UIViewController {
//MARK: - Properties
    var viewObject: [StationViewObject]?
    let viewModel = StationMapViewModel()
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var relocateButton: UIButton!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    private var directionCollection = [MKDirections]()
    var destination = BehaviorRelay<StationViewObject?>(value: nil)
    
    private let bag = DisposeBag()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        centerViewDependsOnUserLocation()
        updateAnnotationState()
        observeRelocateButton()
        observeRefreshButton()
        observeCallBack()
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
                self?.viewModel.input.submit.onNext(())
            }.disposed(by: bag)
    }
    private func observeCallBack(){
        viewModel.output.result
            .subscribe(onNext: { [weak self] val in
                var cellObjects = [StationViewObject]()
                var areas = [String]()
                val.retVal.forEach { data  in
                    let cellObject = data.value.createCellObject()
                    cellObjects.append(cellObject)
                    areas.append(data.value.area)
                }
                self?.viewObject = cellObjects
            }, onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                
            }).disposed(by: bag)
    }
//MARK: - UI Method
    private func initView(){
        mapView.delegate = self
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        let buttonWidthAndHeight = self.view.frame.width*0.15
        NSLayoutConstraint.activate([
            self.relocateButton.widthAnchor.constraint(equalToConstant: buttonWidthAndHeight),
            self.relocateButton.heightAnchor.constraint(equalToConstant: buttonWidthAndHeight)
        ])
        self.relocateButton.layer.cornerRadius = buttonWidthAndHeight / 2
        self.relocateButton.layer.borderWidth = 0.75
        self.relocateButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func updateAnnotationState() {
        guard let viewObject = viewObject, let mapView = mapView else { return }
        mapView.removeAnnotations(mapView.annotations)
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
    func getDirection(to destination: CLLocationCoordinate2D){
        guard let userLocation = LocationHandler.shared.locationManager.location?.coordinate else { return }
        let request = makeDirectionRequest(from: userLocation, to: destination)
        let directions = MKDirections(request: request)
        resetDirections(withNew: directions)
        directions.calculate { [weak self] response, error in
            #warning("Direction error handling")
            guard let response = response else {
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
                                           y: -customCalloutView.bounds.size.height*0.52)
        customCalloutView.isUserInteractionEnabled = true
        view.addSubview(customCalloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        view.image = UIImage(named: "btnLocationSelected")
        getDirection(to: annotation.coordinate)
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
