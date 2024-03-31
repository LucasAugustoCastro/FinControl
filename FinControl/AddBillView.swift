//
//  AddBillView.swift
//  FinControl
//
//  Created by Lucas Castro on 26/03/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore



struct AddBillView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isLogin: Bool
    @State var amount: Double?
    @State var date: Date = Date()
    @State var notes: String = ""
    @State var amountType: String = ""
    @State var newCategory: String = ""
    @State var categories: [Category] = []
    @State var selection: Category?
    @State var showingSheet = false
    @State var newName = "New Category"
    
    var db = Firestore.firestore()
    var typesAmount = ["Income", "Expense", "Saving"]
    
    var body: some View {
        VStack(alignment: .leading){
            Group{
                
                
                Text("Amount")
                TextField("Enter amount", value: $amount, format: .number)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 5)
                    .background(Color(rgba: (253,253,253, 0.83)))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#cfcfd4"))
                    )
                    .keyboardType(.decimalPad)
                
                Text("Category")
                    .padding(.top)
                Menu(selection?.category ?? "Select category") {
                    ForEach(categories) { category in
                        Button(category.category) { selection = category }
                    }
                    Button(action: {showingSheet=true}) {
                        Text("Add category")
                        
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                .background(Color(rgba: (253,253,253, 0.83)))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#cfcfd4"))
                )
                .sheet(isPresented: $showingSheet, content: {
                    VStack(alignment: .leading) {
                        Text("Add Category").font(.headline)
                        InputView(placeholder: "New category", name: $newCategory)
                        
                        Button("Create category"){
                            createCategory()
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(hex: "#1d1d1f"))
                        .cornerRadius(10)
                        .padding(.top)
                        
                    }
                    .padding()
                    .presentationDetents([.height(200)])
                    .presentationDragIndicator(.automatic)
                })
            }
            Text("Date")
                .padding(.top)
            DatePicker(selection: $date, displayedComponents: .date){
                Text("Select date")
                    .foregroundColor(.secondary)
                
            }
            .datePickerStyle(DefaultDatePickerStyle())
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color(rgba: (253,253,253, 0.83)))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#cfcfd4"))
            )
            
            
            
            
            
            Text("Notes")
                .padding(.top)
            InputView(placeholder: "Add notes...", name: $notes)
            
            Picker("Select type", selection: $amountType){
                ForEach(typesAmount, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.top)
            
            
            Spacer()
            Button("Save"){
                saveData()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color(hex: "#1d1d1f"))
            .cornerRadius(10)
            .padding(.top)
        }
        .padding()
        .onAppear{
            getCategories()
        }
        

    }
    func getCategories(){
        print("Executando....")
        guard let currentUser = Auth.auth().currentUser else {
            isLogin = false
            return
        }
        db.collection("category").whereField("userId", isEqualTo: currentUser.uid).getDocuments { querySnapshot, error in
            if let error = error {
                print("Erro ao buscar dados: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                return
            }
            do {
                categories = try documents.compactMap({ document in
                    try document.data(as: Category.self)
                })
            } catch{
                print("Erro ao decodificar documentos: \(error.localizedDescription)")
            }
        }
        
    }
    func saveData(){
        guard let currentUser = Auth.auth().currentUser else {
            isLogin = false
            return
        }
        let documentRef = db.collection("finances").document()
        guard let checkAmount = amount else {
            print("nao tem ")
            return
        }
        guard let selected = selection else {
            print("não tem")
            return
        }
        let data: [String: Any] = [
            "amount": checkAmount,
            "date": date,
            "notes": notes,
            "category": selected.category,
            "amountType": amountType,
            "userId": currentUser.uid
            
        ]
        
        documentRef.setData(data) { error in
            if let erro = error {
                print("\(erro.localizedDescription)")
            } else{
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    func createCategory(){
        guard let currentUser = Auth.auth().currentUser else {
            isLogin = false
            return
        }
        
        let hasCategory = categories.first { category in
            category.category == newCategory
        }
        if (hasCategory != nil) {
            showingSheet=false
            print("Categoria ja existe")
            selection = hasCategory
            return
        }
        
        let documentRef = db.collection("category").document()
        
        
        let data: [String: Any] = [
            "category": newCategory,
            "userId": currentUser.uid
            
        ]
        documentRef.setData(data) { error in
            if let erro = error {
                print("\(erro.localizedDescription)")
            } else{
                showingSheet=false
                let newCat = Category(category: newCategory, userId: currentUser.uid)
                categories.append(newCat)
                selection = newCat
            }
        }
    }
}

struct AddBillView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            AddBillView(isLogin: .constant(true))
        }
    }
}
