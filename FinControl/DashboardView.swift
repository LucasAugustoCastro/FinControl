//
//  DashboardView.swift
//  FinControl
//
//  Created by Lucas Castro on 25/03/24.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct DashboardView: View {
    @Binding var isLogin: Bool
    
    @State private var userName = ""
    @State private var finances: [Finance] = []
    @State private var totalSaved: Double = 0.0
    @State private var totalIncome: Double = 0.0
    @State private var totalExpense: Double = 0.0
    @State private var totalSavedMonth: Double = 0.0
    @State private var image = UIImage()
    
    private let db = Firestore.firestore()
    var body: some View {
        ZStack{
            VStack{
                // MARK: - HEADER
                HStack{

                    Image(uiImage: image)
                        .resizable()
                        .cornerRadius(50)
                        .frame(width: 40.0,height: 40.0)
                        .background(Color.black.opacity(0.2))
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                    
                    VStack{
                        Text("Welcome back,")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(userName)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    NavigationLink(destination: ProfileView(isLogin: $isLogin)) {
                        Image(systemName: "person.fill")
                            .font(.title)
                    }
                    .foregroundColor(.black)
                    
                } // HSTACK - HEADER

                ScrollView{
                    // MARK: - ACCOUNT CARD
                    VStack(alignment: .leading){
                        
                        HStack{
                            Text("Account")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        Text("BRL \(totalIncome+totalExpense, specifier: "%.2f")")
                            .font(.largeTitle)
                            .bold()
                            .padding(.vertical)
                        
                        HStack{
                            VStack{
                                HStack{
                                    Image(systemName: "arrowtriangle.up.fill")
                                        .font(.footnote)
                                    Text("Income")
                                }
                                Text("BRL \(totalIncome, specifier: "%.2f")")
                                    .frame(maxWidth: .infinity)
                            }
                            Divider()
                            VStack{
                                HStack{
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .font(.footnote)
                                    Text("Expenses")
                                }
                                Text("BRL \(totalExpense, specifier: "%.2f")")
                                    .frame(maxWidth: .infinity)
                            }
                            
                        }
                    } // VSTACK - ACCOUNT CARD
                    .padding()
                    .background(.quaternary)
                    .cornerRadius(10)
                    .padding(.bottom)
                    
                    // MARK: - SUMMARY
                    VStack(alignment: .leading){
                        
                        HStack{
                            Text("Summary")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        VStack{
                            HStack{
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                Text("Income")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("R$ \(totalIncome, specifier: "%.2f")")
                            }
                            .padding(.bottom, 3)
                            HStack{
                                
                                Image(systemName: "minus.circle.fill")
                                    .font(.largeTitle)
                                Text("Expenses")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("R$ \(totalExpense, specifier: "%.2f")")
                            }
                            
                        }
                        .padding(.vertical, 5)
                    } // VSTACK - SUMMARY
                    .padding()
                    .background(.quaternary)
                    .cornerRadius(10)
                    .padding(.bottom)
                    
                    // MARK: - SAVING
                    VStack(alignment: .leading){
                        
                        HStack{
                            Text("Saving Summary")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        Text("BRL \(totalSaved, specifier: "%.2f")")
                            .font(.largeTitle)
                            .bold()
                            .padding(.vertical)
                        
                        
                        VStack(alignment: .trailing){
                            HStack{
                                Image(systemName: "arrowtriangle.up.fill")
                                    .font(.footnote)
                                Text("Saved/month")
                            }
                            
                            Text("BRL \(totalSavedMonth, specifier: "%.2f"))")
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        
                    } // VSTACK - ACCOUNT CARD
                    .padding()
                    .background(.quaternary)
                    .cornerRadius(10)
                    .padding(.bottom)
                    
                    // MARK: - FINANCIAL OVERVIEW
                    VStack(alignment: .leading){
                        
                        HStack{
                            Text("Financial Overview")
                                .font(.title)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            NavigationLink("View all") {
                                FinancialOverview(finances: $finances)
                            }
                            .font(.subheadline)
                            .foregroundColor(.black)
                        }
                        
                        ForEach(finances.prefix(5)){ finance in
                            HStack{
                                Image(systemName: finance.amountType == "Expense" ? "minus.circle.fill" :  "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.black)
                                    .cornerRadius(10)
                                VStack(alignment: .leading){
                                    Text("\(finance.notes)")
                                    Text("\(finance.category)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                
                                Text("R$ \(finance.amount, specifier: "%.2f")")
                                
                            }
                        }
                        
                    }
                } // SCROLLVIEW
            }
            // MARK: - FLOATING BUTTON
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    NavigationLink(destination: AddBillView(isLogin: $isLogin)) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(.black)
                            .clipShape(Circle())
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 1))
                    
                
                }
            } // VSTACK - FLOATING BUTTON
            
        }// ZSTACK
        .padding()
        .onAppear{
            fetchUserName()
            fetchFinances()
            loadImageFromFirebase()
            
        }
        
    }
    
    func loadImageFromFirebase() {
        guard let currentUser = Auth.auth().currentUser else {
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
    
    func fetchUserName() {
        guard let userID = Auth.auth().currentUser?.uid else {
            isLogin = false
            return
        }
        
        
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let name = data["name"] as? String {
                    self.userName = name
                }
            } else {
                print("Documento de usuário não encontrado: \(error?.localizedDescription ?? "Erro desconhecido")")
            }
        }
    }
    
    func fetchFinances(){
        print("Executando....")
        guard let currentUser = Auth.auth().currentUser else {
            isLogin = false
            return
        }
        db.collection("finances")
            .whereField("userId", isEqualTo: currentUser.uid)
            .order(by: "date", descending: true)
            .getDocuments { querySnapshot, error in
            if let error = error {
                print("Erro ao buscar dados: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                return
            }
            do {
                finances = try documents.compactMap({ document in
                    try document.data(as: Finance.self)
                })
                sumIncomeValue()
                sumExpensesValue()
                sumSaveValue()
                sumSavedValueMonth()
            } catch{
                print("Erro ao decodificar documentos: \(error.localizedDescription)")
            }
        }
        print("Finalizado")
        
    }
    
    func sumIncomeValue() {
        totalIncome = finances.filter{$0.amountType == "Income"}.reduce(0, { sum, finance in
            sum + finance.amount
        })
    }
    func sumExpensesValue() {
        totalExpense = finances.filter{$0.amountType == "Expense"}.reduce(0, { sum, finance in
            sum - finance.amount
        })
    }
    
    func sumSaveValue() {
        totalSaved = finances.filter{$0.amountType == "Saving"}.reduce(0, { sum, finance in
            sum + finance.amount
        })
    }
    func sumSavedValueMonth() {
        // Obter o mês atual
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)

        // Filtrar finanças para o mês atual
        let filteredFinances = finances.filter { finance in
            let financeMonth = calendar.component(.month, from: finance.date)
            let financeYear = calendar.component(.year, from: finance.date)
            return financeMonth == currentMonth && financeYear == currentYear && finance.amountType == "Saving"
        }

        // Somar os valores das finanças filtradas
        totalSavedMonth = filteredFinances.reduce(0.0) { $0 + $1.amount }
    }
    
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView(isLogin: .constant(true))
        }
    }
}
