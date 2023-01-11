//
//  ContentView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/9/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        //MARK: Redirecting users based on log status
        if logStatus {
            MainView()
        } else {
            LoginView()

        }
      
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
