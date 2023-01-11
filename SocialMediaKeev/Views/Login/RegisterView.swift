//
//  RegisterView.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/15/22.
//MARK: THIS VIEW IS A SHEET FROM LOGIN

import SwiftUI
// MARK: NativeUI image Picker
import PhotosUI
import Firebase
import FirebaseAuth // ??
import FirebaseStorage
import FirebaseFirestore

struct RegisterView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var username: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    
    // MARK: View Properties
    @Environment(\.dismiss) var dismiss
    // MARK: Image Picker Properties
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    //MARK: Loading View
    @State var isLoading: Bool = false
    
    // MARK: Error Handling
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    //MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var userProfileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                Text("Lets Register\nAccount")
                    .font(.largeTitle.bold())
                    .hAlign(.leading)
                Text("Hello user, have a wonderful journey")
                    .font(.title3)
                    .hAlign(.leading)
                
                //MARK: For smaller size optimization
                ViewThatFits {
                    ScrollView(.vertical, showsIndicators: false) {
                        HelperView()
                        
                    }
                    HelperView()
     
                }
                // MARK: Register Button
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Button("Login Now"){
                     // MARK: SOWS LOGINVIEW
                        dismiss()
                        
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                }
                .font(.callout)
                .vAlign(.bottom)
            }
            .vAlign(.top)
            .padding(15)
            //MARK: Loading View
            .overlay(content: {
               LoadingView(show: $isLoading)
            })
            // MARK: Presenting Picker
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem) { newValue in
                // MARK: Extracting UIImage From PhotoItem(PhotosPickerItem)
                if let newValue {
                    Task {
                        do {
                            guard  let imageData = try await newValue.loadTransferable(type: Data.self) else { return}
                            // MARK: UI must be update on the main thread
                            await MainActor.run(body: {
                                userProfilePicData = imageData
                            })

                        } catch {}
                    }
                }
            }
            // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
        }
       
    }
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio( contentMode: .fill)
                    
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                
            }
            .frame(width: 85, height:  85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $username)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
               
            
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
//                    .padding(.top, 25)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            

            
            Button(action: registerUser){
                // MARK: Login Button
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableWithOpacity(username == "" || userBio == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top, 10)

        }
    }
    //MARK: Register User
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                // MARK: step 1 - Registering user in firebase backend
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // MARK: step 2 - Uploading photo to Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                // Step 3: Downloading photo url
                let downLoadURL = try await storageRef.downloadURL()
                // step 4 : Create a user Firestore object
                let user = User(username: username, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downLoadURL)
                // step 5- Saving user doc info to Firebase
                let _ = try Firestore.firestore().collection("users").document(userUID).setData(from: user, completion: { error in
                    if error == nil {
                        // print Saved successfully
                       // try await Auth.auth().currentUser?.delete()
                        print("Saved Successfully!")
                        userNameStored = username
                        self.userUID = userUID
                        userProfileURL = downLoadURL
                        logStatus = true
                    }
                })
                
                
            } catch {
                // MARK: Deleting Created account in case of error
                await setError(error)
            }
        }
        
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
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
       ContentView()
    }
}
