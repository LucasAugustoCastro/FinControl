//
//  SignInView.swift
//  FinControl
//
//  Created by Lucas Castro on 24/03/24.
//

import SwiftUI
import Firebase

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    var body: some View {
        VStack{
            VStack(alignment: .center){
                Image("SignUp")
                Text("FinControl")
                    .font(.title)
                    .bold()
                Text("Take charge of your finances today!")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex:"#f0f0f0"))
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            .ignoresSafeArea()

            VStack{
                InputView(placeholder: "Name", name: $name)
                    .padding(.bottom, 25)
                    .padding(.top, 50)
                InputView(placeholder: "Email", name: $email)
                    .padding(.bottom, 25)
                InputView(placeholder: "Password", name: $password, isSecure: true)
                    .padding(.bottom, 25)
                InputView(placeholder: "Confirm password", name: $confirmPassword, isSecure: true)
                    .padding(.bottom, 25)
                
                Button("Sign In"){
                    createAccount(
                        email: email,
                        password: password,
                        confirmPassword: confirmPassword,
                        name: name
                        
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color(hex: "#1d1d1f"))
                .cornerRadius(10)
                .padding(.top)
            }
            .padding(.horizontal, 40)
        }
    }
    
    private func createAccount(
        email: String,
        password: String,
        confirmPassword:String,
        name: String
    ){
        if password != confirmPassword{
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error)
            } else {
                print("Registered Succefuly")
                
                guard let user = authResult?.user else {
                    print("Usuário não encontrdo após criação de conta")
                    return
                }
                saveUserToFirestore(userID: user.uid, name: name, email: email)
            }
            
            
        }
        
    }
    private func saveUserToFirestore(userID: String, name: String, email: String) {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            let userData: [String: Any] = [
                "name": name,
                "email": email
            ]
            
            userRef.setData(userData) { error in
                if let error = error {
                    print("Erro ao salvar usuário no Firestore: \(error.localizedDescription)")
                } else {
                    print("Usuário salvo no Firestore com sucesso!")
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
