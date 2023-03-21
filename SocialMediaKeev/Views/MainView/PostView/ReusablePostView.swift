//
//  ReusablePostView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 1/3/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ReusablePostView: View {
    var basedOnUID: Bool = false
    var showHeader: Bool = true
    var uid: String = ""
    @Binding var posts:[Post]
    //MARK: View Properties
    @State private var isFetching: Bool = true
    //MARK: Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
   
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if showHeader {
                HeaderView()
                LazyVStack {
                    if isFetching {
                        ProgressView()
                            .padding(.top, 30)
                        
                    } else {
                        if posts.isEmpty {
                            /// No post found on firebase
                            Text("No Posts Found")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 38)
                            
                        } else {
                            /// Display post
                            Posts()
                        }
                        
                        
                    }
                    
                }
                .padding(15)
                
                
            } else {
                //  HeaderView()
                LazyVStack {
                    if isFetching {
                        ProgressView()
                            .padding(.top, 30)
                        
                    } else {
                        if posts.isEmpty {
                            /// No post found on firebase
                            Text("No Posts Found")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 38)
                            
                        } else {
                            /// Display post
                            Posts()
                        }
                        
                        
                    }
                    
                }
                .padding(15)
            }
        }
        //MARK: Scrolling- TODO
//        .simultaneousGesture(
//               DragGesture().onChanged({
//                   let isScrollDown = 0 < $0.translation.height
//                   print(isScrollDown)
//               }))
       
        .refreshable {
            /// Scroll to Refresh
            /// Disabling Refresh for UID based Posts
            guard !basedOnUID else {return}
            isFetching = true
            posts = []
                /// Resetting Pagination Doc - very important
            paginationDoc = nil
            await fetchPosts()
            
        }
        .task {
            /// One time fietch
            guard posts.isEmpty else {return}
            await fetchPosts()
        }
        
    }
    //MARK: Displaying Fetched Posts
    @ViewBuilder
    func Posts() -> some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                /// Updating Post in the array
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                    
                }){
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
                
            } onDelete: {
                /// Remove Post From Array
                withAnimation(.easeInOut(duration: 0.25)){
                    posts.removeAll{ post.id == $0.id}
                }
                
            }
            .onAppear {
                /// When last post appears fetch New Post if present
                if post.id == posts.last?.id && paginationDoc != nil {
  //                  print("Fetch New Posts")
                    Task {
                        await fetchPosts()
                    }
                }
            }
            
            Divider()
                .padding(.horizontal, -15)

            
        }
        
    }
    //MARK: Fetching Posta
    func fetchPosts() async {
        /*
         Update- fetching recent post or fetch
         for a giver user
         */
        do {
            var query: Query!
            //MARK: Implementing Pagination
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
                
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
                
                
            }
            
            /// New query for UID based Documents
            /// /simply filter the post that does not belong to this UID
            if basedOnUID {
                query = query
                    .whereField("userUID", isEqualTo: uid)
            }
            
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                /// Saving the last fetch document so that it can be used for pagination
                paginationDoc = docs.documents.last // PAGINATION
                isFetching = false
            })
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

struct ReusablePostView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
