//
//  PostView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 1/1/23.
//

import SwiftUI

struct PostView: View {
    @State private var recentPost:[Post] = []
    @State private var createNewPost: Bool = false
    var body: some View {
        NavigationStack {
       //     HeaderView()
            ReusablePostView(posts:  $recentPost)
                .hAlign(.center)
                .vAlign(.center)
                .overlay(alignment:.bottomTrailing) {
                    Button {
                        createNewPost.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(13)
                            .background(.black, in:Circle())
                    }
                    .padding(15)
                    
                    
                }
                .toolbar(content: {
                    ToolbarItem(placement:.navigationBarTrailing) {
                        NavigationLink {
                            SearchUserView()
                            
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .tint(.black)
                                .scaleEffect(0.9)
                        }

                    }
                })
                .toolbarBackground(

                                // 1
                                Color.purple,
                                // 2
                                for: .navigationBar)
            
                        
                .navigationTitle("Posts")
                .navigationBarHidden(true)
                
            
            
            
        }
        .fullScreenCover(isPresented: $createNewPost) {
            CreateNewPost { post in
                // Adding Created Posts at the top of Recent Posts
                recentPost.insert(post, at: 0)
                
            }
        }
        
        
    }
    
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
