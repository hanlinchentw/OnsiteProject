//
//  StationAnnotationView.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/28.
//

import UIKit
import MapKit

class StationPointAnnotation: MKPointAnnotation {
    let viewObject: StationViewObject
    
    init(viewObject: StationViewObject) {
        self.viewObject = viewObject
    }

}
