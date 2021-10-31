//
//  Station.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import CoreLocation

struct Val: Codable {
    let retVal: [String: Station]
}
struct Station: Codable{
    let name: String
    let area: String
    let address: String
    let totalNum: String
    let available: String
    let empty: String
    let lastUpdateTime: String
    let latitude: String
    let longitude: String
    
    var isLiked: Bool = false
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        area = try values.decode(String.self, forKey: .area)
        address = try values.decode(String.self, forKey: .address)
        totalNum = try values.decode(String.self, forKey: .totalNum)
        available = try values.decode(String.self, forKey: .available)
        empty = try values.decode(String.self, forKey: .empty)
        lastUpdateTime = try values.decode(String.self, forKey: .lastUpdateTime)
        latitude = try values.decode(String.self, forKey: .latitude)
        longitude = try values.decode(String.self, forKey: .longitude)
    }
    
    
    func createCellObject() -> StationViewObject {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.locale = Locale(identifier:"zh_tw")
        
        let date = formatter.date(from: lastUpdateTime) ?? Date()
        let diffComponents = Calendar.current.dateComponents([ .minute], from: date, to: Date())
        let currentState = "可借:" + "\(self.available) / " + "可停:" + "\(self.empty)"
        let address = self.address
        let totalNum = "Update in " + "\(diffComponents.minute ?? 0) min"
        let walking = "(Walking: 7 min)"
        let lat = self.latitude.toDouble()
        let lon = self.longitude.toDouble()
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        print(location)
        let cellViewObject = StationViewObject(name: name, area: area, currentState: currentState, address: address, totalNum: totalNum, lastUpdateTime: lastUpdateTime,location: location ,walkingTime: walking)
        return  cellViewObject
    }
}

extension Station {
    enum CodingKeys: String, CodingKey {
        case name = "sna"
        case area = "sarea"
        case address = "ar"
        case totalNum = "tot"
        case available = "sbi"
        case empty = "bemp"
        case lastUpdateTime = "mday"
        case latitude = "lat"
        case longitude = "lng"
    }
}
