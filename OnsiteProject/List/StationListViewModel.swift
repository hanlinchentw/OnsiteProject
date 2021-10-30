//
//  StationListViewModel.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import RxSwift
import UIKit

class StationListViewModel {
    
    var disposeBag: DisposeBag = .init()
    
    func createStationsViewObject() -> Observable<AllStationsViewObject> {
        let data = APIManager.shared.getStationInfo()
        let viewObject = data.map { val -> AllStationsViewObject in
            var cellObjects = [StationViewObject]()
            val.retVal.forEach { key, data in
                let cellObject = data.createCellObject()
                cellObjects.append(cellObject)
            }
            let grouping = Dictionary(grouping: cellObjects){ $0.area }
            let areas = Array(grouping.keys)
            let cells = Array(grouping.values)
            
            print("Grouping: ", areas, cells)
            return  AllStationsViewObject(keys: areas, cells: cells)
        }.observe(on: MainScheduler.instance)
        return viewObject
    }
    
    func addStationIntoFavorite(add stationName: String) -> Observable<String> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DBManager.shared.saveStation(stationName, in: context)
    }
    
    
    func getFavoriteStation() -> Observable<[String]> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DBManager.shared.getStation(in: context)
    }
    
    func deleteFavoriteStation(delete stationName: String) -> Observable<String> {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return DBManager.shared.deleteStation(stationName, in: context)
    }
}
