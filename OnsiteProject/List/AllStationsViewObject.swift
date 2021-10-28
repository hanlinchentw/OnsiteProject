//
//  ListViewObject.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import CoreLocation

struct AllStationsViewObject {
    let cells: [StationViewObject]
}

struct StationViewObject {
    let name: String
    let currentState: String // 可借：30 / 可停：70
    let address: String
    let totalNum: String
    let lastUpdateTime: String
    let location: CLLocationCoordinate2D
    let walkingTime: String
}
