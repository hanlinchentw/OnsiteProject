//
//  Extensions.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/28.
//

import UIKit

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
}
