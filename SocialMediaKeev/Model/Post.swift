//
//  Post.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/29/22.
//

import SwiftUI
import FirebaseFirestoreSwift

// MARK: Post Model

struct Post: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var text: String
    var imageURLs: [URL] = []
    var imageReferenceIDs: [String] = []
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
    // MARK: Basic User Info
    var username: String
    var userUID: String
    var userProfileURL: URL
    var user: User?
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURLs
        case imageReferenceIDs
        case publishedDate
        case likedIDs
        case dislikedIDs
//        case bookmarkedIDs
        case username
        case userUID
        case userProfileURL
        case user
    }
}

