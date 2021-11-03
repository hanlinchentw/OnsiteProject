//
//  ListViewObject.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import CoreLocation

struct AllStationsViewObject {
    let keys: [String]
    var cells: [[StationViewObject]]
}

struct StationViewObject {
    let name: String
    let area: String
    let currentState: String // 可借：30 / 可停：70
    let address: String
    let totalNum: String // Total: 100
    let lastUpdateTime: String // Update:
    let location: CLLocationCoordinate2D
    var walkingTime: String
    var isLiked: Bool = false
}
