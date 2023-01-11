//
//  LoginView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/10/22.
// MARK: Loading Page


import SwiftUI
// MARK: NativeUI image Picker
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    
    // MARK: View Properties
    /// shows the register sheet
    @State var createAccount: Bool = false
    // MARK: Error Handling
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    // MARK: Loading View
    @State var isLoading: Bool = false
    //MARK: USER DEFAULTS
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var userProfileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    
    var body: some View {
        VStack(spacing: 10) {
            Text("Lets sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
               
            Text("wWelcome back, youve been missed")
                .font(.title3)
                .hAlign(.leading)
            VStack(spacing: 12) {
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button (action: loginUser){
                    // MARK: Login Button
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)

            }
            // MARK: Register Button
            HStack {
                Text("Dont have an account?")
                    .foregroundColor(.gray)
                Button("Register Now"){
                    createAccount.toggle()
                    
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        // MARK: LOading View
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // MARK: REGISTER VIEW VIA SHEET
        .fullScreenCover(isPresented: $createAccount) {
            
            RegisterView()
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    // MARK: Login User
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                // With the help of Swift concurrency Auth can be done on one line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User found")
                try await fetchUser()
                
            } catch {
                await setError(error)
            }
        }
    }
    // MARK: Reset Password
    func resetPassword() {
        Task {
            do {
                // With the help of Swift concurrency Auth can be done on one line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("User found")
                
                
            } catch {
                await setError(error)
            }
        }
        
    }
    //MARK: If user is found Fetching User data from Firestore
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let user = try await Firestore.firestore().collection("users").document(userID).getDocument(as: User.self)
        // MARK: UI UPDATING MU BE DONE ON THE MAIN THREAD
        // MARK: USER DEFAULTS SET HERE!
        await MainActor.run(body: {
            // Setting User defaults and changing App's Auth Status
            userUID = userID
            userNameStored = user.username
            userProfileURL = user.userProfileURL
             logStatus = true
        })
        
    }
    
    // MARK: Displaying Errors Via Alert
    func setError(_ error: Error) async {
        // MARK: UI must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
       LoginView()
    }
}




// MARK: Register View





