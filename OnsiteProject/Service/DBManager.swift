//
//  DBManager.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/30.
//

import Foundation
import CoreData
import RxSwift


enum DBManagerError: Error {
    case savingError
    case getError
    case deleteError
}

class DBManager: NSObject {
    static let shared: DBManager = .init()
    private let entityName = "Station_db"
    
    func saveStation(_ stationName: String, in context: NSManagedObjectContext) -> Observable<String>{
        return Observable.create { event -> Disposable in
            if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context),
               let object = NSManagedObject(entity: entity, insertInto: context) as? Station_db {
                object.name = stationName
                do {
                    try context.save()
                    event.onNext(stationName)
                }catch{
                    print("Failed to save data in DB... \(error.localizedDescription)")
                    event.onError(DBManagerError.savingError)
                }
            }else {
                event.onError(DBManagerError.savingError)
            }
            event.onCompleted()
            return Disposables.create()
        }
    }
    func getStation(in context: NSManagedObjectContext) -> Observable<[String]>{
        return Observable.create { event -> Disposable in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
            var likeStationNameArray = [String]()
            do {
                let results = try context.fetch(request) as! [Station_db]
                for element in results {
                    if let name = element.name {
                        likeStationNameArray.append(name)
                    }
                }
                event.onNext(likeStationNameArray)
            }catch{
                print("Failed to fetch data in DB ... \(error.localizedDescription)")
                event.onError(DBManagerError.getError)
            }
            event.onCompleted()
            return Disposables.create()
        }
    }
    
    func deleteStation(_ stationName: String, in context: NSManagedObjectContext) -> Observable<String> {
        return Observable.create { event -> Disposable in
            let request = NSFetchRequest<NSManagedObject>(entityName: self.entityName)
            request.predicate = NSPredicate(format: "name == %@", stationName)
            do {
                let results = try context.fetch(request)
                for object in results{
                    context.delete(object)
                    try context.save()
                    event.onNext(stationName)
                }
            }catch {
                print(error.localizedDescription)
                event.onError(DBManagerError.deleteError)
            }
            event.onCompleted()
            return Disposables.create()
        }
    }
}
