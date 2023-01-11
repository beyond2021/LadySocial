//
//  CreateNewPost.swift
//  SocialMediaKeev
//
//  Created by KEEVIN MITCHELL on 12/29/22.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct CreateNewPost: View {
    /// - callbacks
     var onPost: (Post) -> ()
    // MARK: Post properties
    @State private var postText: String = ""
    @State private var postImageData: Data?
    //MARK: Stored User Data From Userdefaults(AppStorage)
    @AppStorage("user_profile_url") private var userProfileURL: URL?
    @AppStorage("user_name") private var userNameStored: String = ""
    @AppStorage("user_UID") private var userUID: String = ""
    //MARK: View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    //MARK: Image Picker
    @State private var showPicker: Bool = false
    @State private var photoItem: PhotosPickerItem? // For native Image Picking
    @FocusState private var showKeyboard: Bool  // @FocusState used to toggle keyboard
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                    
                } label: {
                    Text("Cancel")
                        .font(.callout)
                        .foregroundColor(.black)
                }
                .hAlign(.leading)
                Button(action: createPost) {
                    Text("Post")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)
                        .background(.black, in:Capsule())
                }
                .disableWithOpacity(postText == "")

            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(.gray.opacity(0.05))
                    .ignoresSafeArea()
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    TextField("Whats happening?", text: $postText, axis: .vertical)
                        .focused($showKeyboard)
                    
                    if let postImageData, let image = UIImage(data: postImageData) {
                        GeometryReader {
                            let size = $0.size
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio( contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            //MARK: Delete Button
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            self.postImageData = nil
                                        }
                                        
                                    } label: {
                                        Image(systemName: "trash")
                                            .fontWeight(.bold)
                                            .tint(.red)
                                    }
                                    .padding(10)

                                    
                                }
                            
                        }
                        .clipped()
                        .frame(height: 220)
                    }
                }
                .padding(15)
                
            }
            Divider()
            HStack {
                Button {
                    // Show image picker
                    showPicker.toggle()
                    
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title3)
                        .foregroundColor(.black)
                }
                .hAlign(.leading)
                Button("Done") {
                    // Remove kb
                    showKeyboard = false
                    
                }

            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
        }
        .vAlign(.top)
        //
        .photosPicker(isPresented: $showPicker, selection: $photoItem) //
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    if let rawImageData = try? await newValue
                        .loadTransferable(type: Data.self),
                        let image = UIImage(data: rawImageData),
                        let compressionImageData = image.jpegData(compressionQuality: 0.5) {
                        // UI must be done on main thread
                        await MainActor.run(body: {
                            postImageData = compressionImageData
                            photoItem = nil
                        })
                        
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        /// Loading View
        .overlay{
            LoadingView(show: $isLoading)
        }
    }
    // MARK: Post Content to Firebase
    func createPost() {
        isLoading = true
        showKeyboard = false
        Task {
            do {
                guard let profileURL = userProfileURL else { return }
                // Used to delete post
                let imageReferenceID = "\(userUID)\(Date())"
                let storageRef = Storage.storage().reference().child("Post_Images").child(imageReferenceID)
                if let postImageData {
                    let _ = try await storageRef.putDataAsync(postImageData)
                    let doenloadURL = try await storageRef.downloadURL()
                    /// step 3: Create Post Object with ImageID and URL
                    let post = Post( text: postText, imageURL: doenloadURL, imageReferenceID: imageReferenceID, username: userNameStored,  userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                    
                } else {
                    /// Step2: directly post Text Data to Firebase - since no image
                    let post = Post(text: postText, username: userNameStored, userUID: userUID, userProfileURL: profileURL)
                    try await createDocumentAtFirebase(post)
                    
                }
                
            } catch {
                await setError(error)
            }
        }
        
    }
    //MARK: 2 Types of post being created here
    func createDocumentAtFirebase(_ post: Post) async throws {
        /// - 1: writing document to firebase Firestore
        let doc = Firestore.firestore().collection("Posts").document()
        let _ = try doc.setData(from: post, completion: { error in
            if error == nil {
                /// Post successfully stored in firebase
                isLoading = false
                var updatedPost = post
                updatedPost.id = doc.documentID
                onPost(updatedPost)
                dismiss()
            }
        })
        
        
    }
    // MARK Displaying Error as an alert
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

struct CreateNewPost_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewPost{_ in
            
            
        }
    }
}
