//
//  CoreDataStorage.swift
//  BeappCache
//
//  Created by Antoine Richeux on 05/02/2019.
//

import Foundation
import CoreData

class CoreDataStorage: ExternalStorageProtocol {
    
    var managedObjectContext: NSManagedObjectContext
    var entity: NSEntityDescription?
    var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DataWrapper")
    
    init() {
        let persistentContainer = NSPersistentContainer(name: "BeappCache")
        managedObjectContext = persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "DataWrapper", in: managedObjectContext)
    }
    
    private func retrieveObject(forKey key: String) -> NSManagedObject? {
        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            for object in objects where object.value(forKey: "key") as? String == key {
                return object
            }
            return nil
        } catch {
            print("[ERROR] cannot get data from database with \(error)")
            return nil
        }
    }
    
    func count() -> Int {
        do {
            return try managedObjectContext.count(for: fetchRequest)
        } catch {
            print("[ERROR] cannot return count for Entity \(fetchRequest.entityName ?? "")")
            return 0
        }
    }
    
    func exist(forKey key: String) -> Bool {
        return retrieveObject(forKey: key) != nil
    }
    
    func get<T>(forKey key: String, of type: T.Type) -> CacheWrapper<T>? where T : Decodable, T : Encodable {
        guard let cacheData = retrieveObject(forKey: key)?.value(forKey: "data") as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(CacheWrapper<T>.self, from: cacheData)
    }
    
    func put<T>(data: CacheWrapper<T>, forKey key: String) -> Bool where T : Decodable, T : Encodable {
        guard let _entity = entity else { return false }
        
        do {
            let data = try JSONEncoder().encode(data)
            let dataWrapper = NSManagedObject(entity: _entity, insertInto: managedObjectContext)
            dataWrapper.setValue(key, forKey: "key")
            dataWrapper.setValue(data, forKey: "data")
            try managedObjectContext.save()
            return true
        } catch {
            print("[ERROR] cannot encode data with \(error)")
            return false
        }
    }
    
    func delete(forKey key: String) -> Bool {
        if let object = retrieveObject(forKey: key) {
            managedObjectContext.delete(object)
            return true
        } else {
            return false
        }
    }
    
    func clear() {
        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            for object in objects {
                managedObjectContext.delete(object)
            }
        } catch {
            print("[ERROR] cannot clear data from database with \(error)")
        }
    }
    
    
}
