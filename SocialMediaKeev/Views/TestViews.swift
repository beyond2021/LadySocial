//
//  TestViews.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 1/14/23.
//

import SwiftUI

struct TestViews: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 300, height: 300)
            Circle()
                .fill(Color.white)
                .frame(width: 300, height: 300)
                .shadow(color: .red, radius: 12)
                .shadow(color: .red, radius: 12)
                .shadow(color: .red, radius: 12)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

struct TestViews_Previews: PreviewProvider {
    static var previews: some View {
        TestViews()
    }
}
