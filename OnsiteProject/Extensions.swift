//
//  Extensions.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/28.
//

import UIKit
extension Array {
    func groupStationByArea(stations: [StationViewObject]) -> ([String], [[StationViewObject]]){
        let grouping = Dictionary(grouping: stations) { $0.area }
        let groupingtTupleArray = grouping.sorted { $0.key > $1.key }
        var areas = [String]()
        var objects = [[StationViewObject]]()
        for (key, value) in groupingtTupleArray {
            areas.append(key)
            objects.append(value)
        }
        return (areas, objects)
    }
}
extension Double {
    func rounded(to places: Int) -> Double {
        return (self * pow(10, Double(places))).rounded() / pow(10, Double(places))
    }
}
extension String {
    func toDouble() -> Double{
        return Double(self) ?? 0.0
    }
}
extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension Date{
    static func calculateInterval(from startingDate: Date, to endingDate: Date) -> TimeInterval {
        return startingDate.timeIntervalSinceReferenceDate - endingDate.timeIntervalSinceReferenceDate
    }
    func convertDateFormater(_ dateString: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier:"zh_tw")
        
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "HH:mm"
        return  dateFormatter.string(from: date!)
        
    }
}
