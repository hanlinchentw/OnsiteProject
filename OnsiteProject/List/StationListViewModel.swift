//
//  StationListViewModel.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import RxSwift

class StationListViewModel {
    
    var disposeBag: DisposeBag = .init()
    
    func getStationInfo() -> Single<AllStationsViewObject> {
        let data = APIManager.shared.getStationInfo()
        let viewObject = data.map { val -> AllStationsViewObject in
            var cellObjects = [StationViewObject]()
            val.retVal.forEach { key, UbikeData in
                let cellObject = UbikeData.createCellObject()
                cellObjects.append(cellObject)
            }
            return  AllStationsViewObject(cells: cellObjects)
            
        }.observe(on: MainScheduler.instance)
        return viewObject
    }
}

//extension StationListViewModel {
//    private func createListViewObject(){
//
//    }
//}
