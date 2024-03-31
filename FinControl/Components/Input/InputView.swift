//
//  InputView.swift
//  FinControl
//
//  Created by Lucas Castro on 24/03/24.
//

import SwiftUI

struct InputView: View {
    var placeholder: String = ""
    @Binding var name: String
    var isSecure: Bool = false
    @State var showPass: Bool = false
    var body: some View {
        if isSecure{
            HStack{
                if showPass {
                    TextField(placeholder, text: $name)
                        .autocapitalization(.none)
                } else {
                    SecureField(placeholder, text: $name)
                }
                Button(action: {
                    showPass.toggle()
                }){
                    Image(systemName: showPass ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 5)
            .background(Color(rgba: (253,253,253, 0.83)))
            .cornerRadius(10)
            .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#cfcfd4"))
            )
        } else{
            TextField(placeholder, text: $name)
                .padding(.vertical, 20)
                .padding(.horizontal, 5)
                .background(Color(rgba: (253,253,253, 0.83)))
                .cornerRadius(10)
                .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#cfcfd4"))
                )
                .autocapitalization(.none)
        }
        
        
            

    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(placeholder: "Nome: ", name:.constant(""), isSecure: true)
    }
}
