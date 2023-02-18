//
//  ReusableProfileContent.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/15/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    
    var user: User
    @State private var fetchedPosts:[Post] = []
    @State var showHeader: Bool = false
    //var isFollowed: Bool = 
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                HStack(spacing: 20) {
                    WebImage(url: user.userProfileURL).placeholder{
                    // MARK: Placeholder Image
                    Image("NullProfile")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height:  100)
                .clipShape(Circle())
                .glow(color: .purple, radius: 36)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        // MARK: Displaying bio link if given during sign up
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                        
                    }
                    .hAlign(.leading)
                }
                
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
                // Action Button
                ProfileActionButtonView(user: user)
                    .padding(.bottom, 15)
                /*
                 This is why we create a reuable post view.
                 It fetches all the post associated with the user
                 */
                ReusablePostView(basedOnUID: true, showHeader:  showHeader, uid: user.userUID, posts: $fetchedPosts)
                
            }
            .padding(15)
            
        }
    }
}

