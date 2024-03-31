//
//  ProfileView.swift
//  FinControl
//
//  Created by Lucas Castro on 30/03/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
struct ProfileView: View {
//    @State private var image: Image?
    @Binding var isLogin: Bool
    @State private var isShowingImagePicker = false
    @State private var isImagePickerSourceTypeCamera = false
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var image = UIImage()
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            
            Image(uiImage: image)
                .resizable()
                .cornerRadius(50)
                .frame(width: 100, height: 100)
                .background(Color.black.opacity(0.2))
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                
            Button("Edit Image"){
                showSheet = true
            }
            .padding()
            .foregroundColor(.white)
            .background(Color(hex: "#1d1d1f"))
            .cornerRadius(10)
            .padding(.top)
            
            
            Text("Name")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            InputView(placeholder: "Insert name", name: $userName)
            
            Text("Email Address")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            InputView(placeholder: "Inser your email", name: $userEmail)
            
            Spacer()
            Button("Sign Out"){
                do {
                    try Auth.auth().signOut()
                    isLogin = false
                    
                } catch let signOutError as NSError {
                    print("Erro ao deslogar usuario. Erro(\(signOutError))")
                }

            }
        }
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
        .onAppear {
            fetchUserInfo()
            loadImageFromFirebase()
        }
        .padding()

    }
    
    func fetchUserInfo() {
        guard let userID = Auth.auth().currentUser?.uid else {
            isLogin = false
            return
        }
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let name = data["name"] as? String, let email = data["email"] as? String {
                    self.userName = name
                    self.userEmail = email
                }
            } else {
                print("Documento de usuário não encontrado: \(error?.localizedDescription ?? "Erro desconhecido")")
            }
        }
    }
    
    func loadImageFromFirebase() {
        guard let currentUser = Auth.auth().currentUser else {
            isLogin = false
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images").child("\(currentUser.uid).jpg")
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Erro ao recuperar a imagem do Firebase Storage: \(error.localizedDescription)")
                return
            }
            
            if let imageData = data, let uiImage = UIImage(data: imageData) {
                self.image = uiImage
            }
        }
    }
        
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(isLogin: .constant(true))
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                uploadImageToFirebase(image: image)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func uploadImageToFirebase(image: UIImage) {
            guard let currentUser = Auth.auth().currentUser else {
                print("Não há usuário autenticado")
                return
            }

            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                print("Não foi possível converter a imagem para dados JPEG")
                return
            }

            let storage = Storage.storage()
            let storageRef = storage.reference().child("profile_images").child("\(currentUser.uid).jpg")

            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Erro ao fazer upload da imagem para o Firebase Storage: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Erro ao obter a URL de download da imagem do Firebase Storage: \(error.localizedDescription)")
                        return
                    }

                    if let downloadURL = url {
                        print("URL de download da imagem do Firebase Storage: \(downloadURL.absoluteString)")

                        // Agora você tem o URL de download da imagem.
                        // Você pode salvá-lo na tabela do usuário ou onde quer que precise.
                        // Exemplo:
                        Firestore.firestore().collection("users").document(currentUser.uid).updateData(["profileImageURL": downloadURL.absoluteString])
                    }
                }
            }
        }
    }
}
