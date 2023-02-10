//
//  ProfileActionButtonView.swift
//  Soursop
//
//  Created by KEEVIN MITCHELL on 6/29/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ProfileActionButtonView: View {
    // MARK: passed all the way dow to here as an observed object
    var user: User
    // Temp
    let currentUser = Auth.auth().currentUser
    
    var currentUserID: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    var body: some View {
        if user.userUID == currentUser?.uid  {
            // edit profile button
            Button(action: {}) {
                Text("Edit Profile")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 360, height: 32)
                    .foregroundColor(.black
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.purple, lineWidth: 1)
                        
                    )
            }
        } else {
            // follow and message button
            
            HStack {
                Button(action: { user.followersIDs.contains(currentUserID) ? unFollowUser() : followUser()}) {
                    Text(user.followersIDs.contains(Auth.auth().currentUser!.uid) ? "Following" : "Follow")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 172, height: 32)
                        .background(user.followersIDs.contains(currentUserID) ? Color.white : .purple)
                        .foregroundColor(user.followersIDs.contains(currentUserID) ? .black : .white
                        )
                    
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.purple, lineWidth: user.followersIDs.contains(currentUserID) ? 1 : 0)
                            
                        )
                }.cornerRadius(3)
                Button(action: {}) {
                    Text("Message")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 172, height: 32)
                        .foregroundColor(.black
                        )
                    
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.purple, lineWidth: 1)
                            
                        )
                }
            }
        }
    }
    func followUser() {
        print("follow User")
        
        Task {
            let userID = user.userUID
            guard let CUser = Auth.auth().currentUser?.uid else {return}
            if user.followersIDs.contains(CUser) {
                try await Firestore.firestore().collection("users").document(userID).updateData([
                    "followersIDs": FieldValue.arrayRemove([CUser])
                ])
                
            } else {
                /// Adding user to liked array and removing id from disliked array(if added prior)
                try await Firestore.firestore().collection("users").document(userID).updateData([
                    "followersIDs": FieldValue.arrayUnion([CUser]),
                ])
            }
            await MainActor.run {
                
            }
        }
        
    }
    func unFollowUser() {
        print("Unfollow User")
        Task {
            let userID = user.userUID
            guard let CUser = Auth.auth().currentUser?.uid else {return}
            // postLikeNotification(postID: postID)
            if user.followersIDs.contains(CUser) {
                try await Firestore.firestore().collection("users").document(userID).updateData([
                    "followersIDs": FieldValue.arrayRemove([CUser]),
                    //  "followingIDs": FieldValue.arrayRemove([CUser])
                ])
                
            } else {
                /// Adding user to liked array and removing id from disliked array(if added prior)
                try await Firestore.firestore().collection("users").document(userID).updateData([
                    "followersIDs": FieldValue.arrayUnion([CUser]),
                ])
            }
            await MainActor.run {
                
            }
        }
        
    }
}

struct ProfileActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
