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
    var imageURL: URL?
    var imageReferenceID: String = ""
    var publishedDate: Date = Date()
    var likedIDs: [String] = []
    var dislikedIDs: [String] = []
//    var bookmarkedIDs: [String] = []
    // MARK: Basic User Info
    var username: String
    var userUID: String
    var userProfileURL: URL
    enum CodingKeys: CodingKey {
        case id
        case text
        case imageURL
        case imageReferenceID
        case publishedDate
        case likedIDs
        case dislikedIDs
//        case bookmarkedIDs
        case username
        case userUID
        case userProfileURL
    }
}

/*
 {"error":{"message":"Request failed with status code 401","name":"Error","stack":"Error: Request failed with status code 401\n    at createError (/opt/render/project/src/server/node_modules/axios/lib/core/createError.js:16:15)\n    at settle (/opt/render/project/src/server/node_modules/axios/lib/core/settle.js:17:12)\n    at IncomingMessage.handleStreamEnd (/opt/render/project/src/server/node_modules/axios/lib/adapters/http.js:322:11)\n    at IncomingMessage.emit (events.js:388:22)\n    at endReadableNT (internal/streams/readable.js:1336:12)\n    at processTicksAndRejections (internal/process/task_queues.js:82:21)","config":{"transitional":{"silentJSONParsing":true,"forcedJSONParsing":true,"clarifyTimeoutError":false},"transformRequest":[null],"transformResponse":[null],"timeout":0,"xsrfCookieName":"XSRF-TOKEN","xsrfHeaderName":"X-XSRF-TOKEN","maxContentLength":-1,"maxBodyLength":-1,"headers":{"Accept":"application/json, text/plain, *","Content-Type":"application/json","User-Agent":"OpenAI/NodeJS/3.1.0","Authorization":"Bearer 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","Content-Length":136},"method":"post","data":"{\"model\":\"text-davinci-003\",\"prompt\":\"hello\\n\",\"temperature\":0,\"max_tokens\":3000,\"top_p\":1,\"frequency_penalty\":0.5,\"presence_penalty\":0}","url":"https://api.openai.com/v1/completions"},"status":401}}
 
 */
