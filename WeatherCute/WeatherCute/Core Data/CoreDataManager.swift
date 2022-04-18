//
//  CoreDataManager.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/1/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
	
	static var shared = CoreDataManager()
	
	lazy var managedObjectContext: NSManagedObjectContext = { [unowned self] in
		var container = self.persistentContainer
		return container.viewContext
		}()
	
	private lazy var persistentContainer: NSPersistentContainer = {
		var container = NSPersistentContainer(name: "WeatherLocation")

        let storeURL = URL.storeURL(for: "group.com.kduncan-welke.WeatherCute", databaseName: "WeatherCuteDatabase")

        // solution for moving core data into database from https://stackoverflow.com/questions/52191523/ios-11-how-to-migrate-existing-core-data-to-shared-app-group-for-use-in-extensi
        var defaultURL: URL?

        if let storeDescription = container.persistentStoreDescriptions.first, let url = storeDescription.url {
            defaultURL = FileManager.default.fileExists(atPath: url.path) ? url : nil
        }

        if defaultURL == nil {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
		
		container.loadPersistentStores(completionHandler: { [unowned container] (storeDescription, error) in
			if var error = error as NSError? {
				fatalError("unresolved error \(error), \(error.userInfo)")
			}
            if let url = defaultURL, url.absoluteString != storeURL.absoluteString {
                let coordinator = container.persistentStoreCoordinator
                if let oldStore = coordinator.persistentStore(for: url) {
                    do {
                        try coordinator.migratePersistentStore(oldStore, to: storeURL, options: nil, withType: NSSQLiteStoreType)
                    } catch {
                        print(error.localizedDescription)
                    }

                    // delete old store
                    let fileCoordinator = NSFileCoordinator(filePresenter: nil)
                    fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: { url in
                        do {
                            try FileManager.default.removeItem(at: url)
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                }
            }
        })
    return container
}()
}

/*
 private lazy var persistentContainer: NSPersistentContainer = {
     var container = NSPersistentContainer(name: "WeatherLocation")

     let storeURL = URL.storeURL(for: "group.com.kduncan-welke.WeatherCute", databaseName: "WeatherCuteDatabase")
     let storeDescription = NSPersistentStoreDescription(url: storeURL)

     container.persistentStoreDescriptions = [storeDescription]

     container.loadPersistentStores() { storeDescription, error in
         if var error = error as NSError? {
             fatalError("unresolved error \(error), \(error.userInfo)")
         }

         storeDescription.shouldInferMappingModelAutomatically = true
         storeDescription.shouldMigrateStoreAutomatically = true
     }

     return container
 }()
 */

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container not created")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
