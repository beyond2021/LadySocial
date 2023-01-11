//
//  SearchUserView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 1/10/23.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    // View Properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            ForEach(fetchedUsers) { user in
                NavigationLink{
                    ReusableProfileContent(user: user)
                    /*
                     This is why we created a reusable profile view
                     We just pass in a user we geta all the details
                     */
                    
                    } label: {
                        Text(user.username)
                            .font(.callout)
                            .hAlign(.leading)
                    
                }
            }
            
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search Users")
        .searchable(text: $searchText)
        .onSubmit(of: .search,{
            //MARK: Fetch user from Firebase
            Task{ await searchUsers()}
            
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUsers = []
            }
        })

    }
    func searchUsers() async {
        do {
//            let queryLowerCased = searchText.lowercased()
//            let queryUpperCased = searchText.uppercased()
            let documents = try await Firestore.firestore().collection("users")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}")
                .getDocuments()
            let users = try  documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
                
            }
            // User must be updated on main thread
            await MainActor.run(body: {
                fetchedUsers = users
                print(fetchedUsers.count)
            })
            
        } catch {
            print(error)
        }
        
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
