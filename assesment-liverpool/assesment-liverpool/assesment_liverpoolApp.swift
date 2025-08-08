//
//  assesment_liverpoolApp.swift
//  assesment-liverpool
//
//  Created by Charlie Mora on 08/08/25.
//

import SwiftUI

@main
struct assesment_liverpoolApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
