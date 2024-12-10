//
//  NewsReaderAppApp.swift
//  NewsReaderApp
//
//  Created by prema janoti on 05/12/24.
//

import CoreData
import SwiftUI

@main
struct MyApp: App {
    // Setup the Core Data context
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "BookmarkModel") 
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)")
            }
        }
    }
}
