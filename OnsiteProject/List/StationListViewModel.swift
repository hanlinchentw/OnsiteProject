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
    
    func getStationInfo(){
        let data = APIManager.shared.getStationInfo()
        print(data)
        
    }
}
