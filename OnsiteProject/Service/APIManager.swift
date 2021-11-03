//
//  NetworkService.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/27.
//

import Foundation
import RxSwift

enum APIRequestError: Error {
    case noInternetError
    case wrongUrlFormat
    case badRequest
    case serverError
    case decodeError
    case dataNull
}
class APIManager {
    static let shared = APIManager()
    static let apiString = "https://tcgbusfs.blob.core.windows.net/blobyoubike/YouBikeTP.json"
    
    func getStationInfo() -> Observable<Val>{
        return self.get().flatMap { data -> Observable<Val> in
            if let data = data {
                do{
                    let result = try JSONDecoder().decode(Val.self, from: data)
                    return Observable<Val>.just(result)
                }catch {
                    return Observable.error(APIRequestError.decodeError)
                }
            }
            return Observable.error(APIRequestError.dataNull)
        }
    }

    private func get() -> Observable<Data?> {
        return Observable.create { event -> Disposable in
            let url = URL(string: APIManager.apiString)
            let request = URLRequest(url: url!)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if !NetworkMonitor.shared.isConnected { event.onError(APIRequestError.noInternetError) }
                if error != nil {
                    event.onError(APIRequestError.wrongUrlFormat)
                    print(error?.localizedDescription)
                }
                if let res = response as? HTTPURLResponse {
                    if (400...499).contains(res.statusCode){
                        event.onError(APIRequestError.badRequest)
                    }else if (500...599).contains(res.statusCode){
                        event.onError(APIRequestError.serverError)
                    }else if (200...299).contains(res.statusCode) {
                        if let data = data,
                           let JSONString = String(data: data, encoding: String.Encoding.utf8){
                            print("JSONString = " + JSONString)
                            event.onNext(data)
                            event.onCompleted()
                        }
                    }
                }
            }
            task.resume()
            return Disposables.create()
        }
    }
}
