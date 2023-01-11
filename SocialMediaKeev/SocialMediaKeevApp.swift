//
//  SocialMediaKeevApp.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/9/22.
//

import SwiftUI
import Firebase

@main
struct SocialMediaKeevApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
