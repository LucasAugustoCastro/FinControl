//
//  SignInView.swift
//  FinControl
//
//  Created by Lucas Castro on 24/03/24.
//

import SwiftUI

struct SignUpView: View {
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
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
                InputView(placeholder: "Nome", name: $name)
                    .padding(.bottom, 25)
                    .padding(.top, 50)
                InputView(placeholder: "Email", name: $email)
                    .padding(.bottom, 25)
                InputView(placeholder: "Senha", name: $password)
                    .padding(.bottom, 25)
                
                Button("Sign In"){
                    
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
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
