//
//  CustomNavBar.swift
//  LadySocial
//
//  Created by KEEVIN MITCHELL on 2/5/23.
//

import SwiftUI
struct CustomNavBar<Content>: View where Content: View {
    
    let title: String
    let content: Content
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Image("12345")
                        .resizable()
                        .frame(height: 135)
                        .edgesIgnoringSafeArea(.all)
                    Spacer()
                }
                content
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }
}
