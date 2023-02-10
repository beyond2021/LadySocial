//
//  PostCardView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 1/3/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct PostCardView: View {
    var post: Post
   
    //MARK: Callbacks
    var onUpdate: (Post) -> ()
    var onDelete: () -> ()
    //MARK: View Properties from userdefaults
    @AppStorage("user_UID") private var userUID: String = ""
    //MARK: For Live Updates
    @State private var docListener: ListenerRegistration?
    // Enlagre Image
    @State private var selected: Bool = false
    // MARK: Post on screen
    @State var onScreen: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 25) {
            ZStack {
                NavigationLink(destination:ProfileView(userID: post.userUID)){
                    
                    WebImage(url: post.userProfileURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle()) .padding()
                        .glow(color: .teal, radius: 36)
//                        .onTapGesture {
//                            print("Launch Profile")
//                        }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(post.username)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical, 8)
                    .glow(color: .gray, radius: 36)
                    .padding(.bottom, 15)
                /// Post Image if Any
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio( contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                    
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                           .glow(color: .purple, radius: 36)
                          
                        
                            .onTapGesture {
                                
                                    withAnimation(.easeInOut) {
                                        selected.toggle()
                                    }
                                
                                    
                            }
                            .scaleEffect(self.selected && onScreen ? 1.5 : 1)
                      
                    }
                    .frame(height: 400)
                    
                    
                }
                    
                PostInteraction()
                    .padding(.top, 15)
                
            }
            .onDisappear{
                selected = false
            }
            
            
        }
        .hAlign(.leading)
        //MARK: Delete Button - if itsnthe Author of the Post
        .overlay(alignment: .topTrailing, content: {
            if post.userUID == userUID {
                Menu {
                    Button("Delete Post", role: .destructive, action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                        
                }
                .offset(x: 8)

            }
            
        })
        .onAppear{
            onScreen = true
            /*
             When the post is visible on the screen
             the document listener is added
             otherwise the listener is removed.
             
             Since we used LazyVStack earlier,
             onAppear and onDisappear will be called
             when the view enters or leaves
             */
            // Adding on once
            if docListener == nil {
                guard let postID = post.id else { return }
                docListener = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists {
                            /// Document Updated
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                            
                        } else {
                            /// Document Deleted, Fetch updated Document,
                            onDelete()
                        }
                        
                    }
                })
                
            }
        }
        .onDisappear {
            // Applying snapshot lisyener only when Post is on the screen
            // Else remove it
            if let docListener {
                docListener.remove()
                self.docListener = nil
            }
            onScreen = false
        }
    }
    //Mark: Like/ Dislike Interaction
    @ViewBuilder
    func PostInteraction() -> some View {
        HStack(spacing: 6) {
            Button(action: likePost) {
                Image(systemName: post.likedIDs.contains(userUID)  ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .foregroundColor(.teal)
                
            }
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            
            Button(action: dislikePost) {
               
                Image(systemName: post.dislikedIDs.contains(userUID)  ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .foregroundColor(.teal)
                
            }
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            
            
            Button {
                
            } label: {
                Image(systemName: "bookmark")
            }

        }
        .foregroundColor(.teal)
        .padding(.vertical, 8)
        
    }
    //MARK: Loiking Posts
    /*
     Remove the user,s uid from the relavant array if the posts
     has already receved likes; if not add the users UID to the array
     For example if the user liked the post before disliking it,
     the UID must be moved frm the liked array list to the disliked array list
     */
    func likePost() {
        // TODO send notification
        
        Task {
            guard let postID = post.id else { return }
            postLikeNotification(postID: postID)
            if post.likedIDs.contains(userUID) {
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
                
            } else {
                /// Adding user to liked array and removing id from disliked array(if added prior)
               try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIOs": FieldValue.arrayRemove([userUID])
                ])
                
                
            }
        }
    }
    //MARK: Disliked Post
    func dislikePost(){
        Task{
            guard let postID = post.id else{return}
            if post.dislikedIDs.contains(userUID){
                /// Removing User ID From the Array
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }else{
                /// Adding User ID To Liked Array and removing our ID from Disliked Array (if Added in prior)
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID]),
                    "dislikedIDs": FieldValue.arrayUnion([userUID])
                ])
            }
        }
    }
    //MARK: Bookmarked Post
    func bookmarkPost() {
//        guard let user = Auth.auth().currentUser?.uid else {return}
//        guard let postID = post.id else { return }
        
    }
    //MARK: Delete Post
    func deletePost() {
        Task {
            /// Step 1: Delete Image from Firebase Storage if present
            do {
                if post.imageReferenceID != "" {
                    try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                /// Delete firebase document
                guard let postID = post.id else { return }
                try await Firestore.firestore().collection("Posts").document(postID).delete()
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    //MARK: Post Notification
    func postLikeNotification(postID: String) {
        // 1: Get the user id from the postid
        
        // 2: send notification to the user device
    }
    
}

