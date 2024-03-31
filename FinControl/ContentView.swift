//
//  ContentView.swift
//  FinControl
//
//  Created by Lucas Castro on 24/03/24.
//

import SwiftUI
import Firebase
struct ContentView: View {
    @State var islogin: Bool = true
    var body: some View {
        NavigationView{
            if islogin {
                DashboardView(isLogin: $islogin)
            }
            else {
                LogInView(isLogin: $islogin)
            }
        }
        .onAppear{
            if (Auth.auth().currentUser == nil){
                islogin = false
           } else {
               islogin = true
           }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
