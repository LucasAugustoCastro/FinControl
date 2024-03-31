//
//  LogInView.swift
//  FinControl
//
//  Created by Lucas Castro on 24/03/24.
//

import SwiftUI
import Firebase

struct LogInView: View {
    @State var email: String = ""
    @State var password: String = ""
    @Binding var isLogin: Bool
    var body: some View {
        VStack{
            Image("startImage")
            Text("Welcome back!")
                .font(.largeTitle)
                .bold()
            
            InputView(placeholder: "Email", name: $email)
            InputView(placeholder: "Password", name: $password, isSecure: true)
            
            Button("Log In"){
                login(email: email, password: password)
            }
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color(hex: "#1d1d1f"))
            .cornerRadius(10)
            .padding(.top)
            
            LabelledDivider(label: "or")
            
            NavigationLink(destination: SignUpView()) {
                Text("Sign Up")
            }
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color(hex: "#1d1d1f"))
            .cornerRadius(10)
            
            
        }
        .padding(24)
    }
    private func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
//                errorMessage = error.localizedDescription
                print(error.localizedDescription)
            } else {
                isLogin = true
                print("logado")
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView(isLogin: .constant(false))
    }
}

struct LabelledDivider: View {

    let label: String
    let horizontalPadding: CGFloat
    let color: Color

    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
            line
        }
    }

    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}
