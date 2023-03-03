//
//  SkiForce2App.swift
//  SkiForce2
//
//  Created by Joachim Mjelde on 3/2/23.
//

import SwiftUI

@main
struct SkiForce2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
