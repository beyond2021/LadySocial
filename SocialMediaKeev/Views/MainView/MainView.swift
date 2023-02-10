//
//  MainView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/15/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        // MARK: Tab View with Recent Post and Profile Tabs
        TabView {
            PostView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Posts")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        // MARK: Changing Tab Label tint
        .tint(.teal)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
