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
    var body: some View {
        
        TextField(placeholder, text: $name)
            .padding(.vertical, 20)
            .padding(.horizontal, 5)
            .background(Color(rgba: (253,253,253, 0.83)))
            .cornerRadius(10)
            .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#cfcfd4"))
            )
            

    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(placeholder: "Nome: ", name:.constant(""))
    }
}
