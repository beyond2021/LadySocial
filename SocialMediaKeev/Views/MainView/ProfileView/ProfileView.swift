//
//  ProfileView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/15/22.
//

import SwiftUI
import Firebase
// Deletion
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    
    //MARK: My Profile Data
    @State private var myProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                if  let myProfile  {
                    ReusableProfileContent(user: myProfile)
                        .refreshable {
                            // MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                            
                        }
                    
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // MARK: Two Actions
                        //!: Logout
                        Button("Logout", action:logOutUser)
                        //2: Delete Account
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }

                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
            
        }
        // MARK: Fetching user data 1\
        .task {
            // MARK: initial Fetch
            // this modifier is like on appear
            // So fetching for the first time only
            if myProfile != nil {return}
            await fetchUserData()
        }
    }
    // MARK: Fetching user data
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else {return}
        guard let user = try? await Firestore.firestore().collection("users").document(userUID).getDocument(as: User.self) else {return}
        //MAIN THREAD
        await MainActor.run(body: {
            myProfile = user
        })
        
        
    }
    // MARK: Logging User Out
    func logOutUser() {
        try? Auth.auth().signOut()
        logStatus = false
        
    }
    // MARK: Deleting User Entire Account
    func deleteAccount() {
        isLoading = true
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                // Step 1: Deleting Profile image
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                // Step 2: Delete Firestore User Document
                try await Firestore.firestore().collection("users").document(userUID).delete()
                // Final Step - Delete Auth Account and Settingn Log status to false
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            
                
            } catch {
                await setError(error)
                
            }
            
            
        }
    }
    // MARK: Setting Error
    func setError(_ error: Error) async {
        // MARK: UI must be ran on main thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
