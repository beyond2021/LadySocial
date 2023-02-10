//
//  User.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/12/22.
//

import SwiftUI
import FirebaseFirestoreSwift // NEEDED IN THE MODEL
import FirebaseAuth


struct User: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    var bookmarked: [String] = []
    var followingIDs: [String] = []
    var followersIDs: [String] = []
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case bookmarked
        case userProfileURL
        case followingIDs
        case followersIDs
    }
//    var isCurrentUser: Bool {
//        return ((Auth.auth().currentUser?) != nil)
//    }
  
}
