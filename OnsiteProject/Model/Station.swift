//
//  Station.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
struct Val: Codable {
    let retVal: [String: UbikeData]
}
struct UbikeData: Codable{
    let sareaen: String
//    let name: String
//    let total: Int
//    let available: Int
//    let empty: Int
//    let latitude: Double
//    let longitude: Double
//    let lastFreshTime: Int
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        station = try values.decode(String.self, forKey: .station)
//        name = try values.decode(String.self, forKey: .name)
//        total = try values.decode(Int.self, forKey: .total)
//        available = try values.decode(Int.self, forKey: .available)
//        empty = try values.decode(Int.self, forKey: .empty)
//        latitude = try values.decode(Double.self, forKey: .latitude)
//        longitude = try values.decode(Double.self, forKey: .longitude)
//        lastFreshTime = try values.decode(Int.self, forKey: .lastFreshTime)
//    }
}
