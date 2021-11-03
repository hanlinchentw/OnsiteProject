//
//  StationMapViewModel.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/29.
//

import Foundation
import RxSwift

class StationMapViewModel {
    let input: StationMapViewModel.Input
    let output:StationMapViewModel.Output
    
    let submitObject = PublishSubject<Void>()
    
    struct Input {
        let submit: AnyObserver<Void>
    }
    
    struct Output {
        let result: Observable<Val>
    }
    init() {
        input = Input(submit: submitObject.asObserver())
        let apiRequest = submitObject .flatMap{ return APIManager.shared.getStationInfo() }
        output = Output(result: apiRequest)
    }
}
