//
//  StationListViewModel.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import RxSwift
import UIKit

class StationViewModel {
    
    var disposeBag: DisposeBag = .init()
    
    func getAllStationsViewObject() -> Observable<AllStationsViewObject> {
        let data = APIManager.shared.getStationInfo()
        let viewObject = data.map { val -> AllStationsViewObject in
            var cellObjects = [StationViewObject]()
            val.retVal.forEach { key, data in
                let cellObject = data.createStationViewObject()
                cellObjects.append(cellObject)
            }
            let (keys, cells) = Array<Any>().groupStationByArea(stations: cellObjects)
            return  AllStationsViewObject(keys: keys, cells: cells)
        }.observe(on: MainScheduler.instance)
        return viewObject
    }
    func addFavoriteStation(add stationName: String) -> Observable<String> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DBManager.shared.saveStation(stationName, in: context).observe(on: MainScheduler.instance)
    }
    func getFavoriteStation() -> Observable<[String]> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DBManager.shared.getStation(in: context).observe(on: MainScheduler.instance)
    }
    func deleteFavoriteStation(delete stationName: String) -> Observable<String> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DBManager.shared.deleteStation(stationName, in: context).observe(on: MainScheduler.instance)
    }
}
