//
//  StationMapViewController.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import UIKit
import MapKit
import CoreLocation

class StationMapViewController: UIViewController {
//MARK: - Properties
    var viewObject: AllStationsViewObject?
    @IBOutlet weak var mapView: MKMapView!
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        centerViewDependsOnUserLocation()
        updateAnnotationState()
    }
//MARK: - UI Method
    private func initView(){
        mapView.delegate = self
    }
    private func updateAnnotationState() {
        guard let viewObject = viewObject, let mapView = mapView else { return }
        var annos = [StationPointAnnotation]()
        viewObject.cells.forEach { object in
            let annotation = StationPointAnnotation()
            annotation.title = object.name
            annotation.subtitle = object.currentState
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
}

extension StationMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation { return }
        let customCalloutView : StationListCell = .fromNib()
        customCalloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -customCalloutView.bounds.size.height*0.52)
        view.addSubview(customCalloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: MKAnnotationView.self) {
            view.subviews.forEach { subview in
                if let subview = subview as? StationListCell {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}
