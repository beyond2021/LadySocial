//
//  User.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/12/22.
//

import SwiftUI
import FirebaseFirestoreSwift // NEEDED IN THE MODEL

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var userBio: String
    var userBioLink: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    var bookmarked: [String] = []
    enum CodingKeys: CodingKey {
        case id
        case username
        case userBio
        case userBioLink
        case userUID
        case userEmail
        case bookmarked
        case userProfileURL
    }
}
