//
//  FinancialOverview.swift
//  FinControl
//
//  Created by Lucas Castro on 30/03/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct FinancialOverview: View {
    @Binding var finances: [Finance]
    @State private var selectedMonth: String = ""
    @State private var months:[String] = []
    @State var filterFinances:[Finance] = []
    
    var body: some View {
        
        VStack(alignment: .leading) {
            List{
                ForEach(filterFinances.indices, id: \.self) { index in
                    HStack{
                        Image(systemName: filterFinances[index].amountType == "Expense" ? "minus.circle.fill" :  "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(.black)
                            .cornerRadius(10)
                        VStack(alignment: .leading){
                            Text("\(filterFinances[index].notes)")
                            Text("\(filterFinances[index].category)")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        
                        VStack{
                            Text("R$ \(filterFinances[index].amount, specifier: "%.2f")")
                            
                            Text("\(formatDate(filterFinances[index].date))")
                                .font(.system(size: 12))
                        }
                        
                    }
                    
                }
                .onDelete{ indexSet in
                    deleteItem(at: indexSet)
                }
            }
            .listStyle(.plain)

            
            
        }
        .navigationTitle("Finacial overview")
        .padding()
        .onAppear{
            months = allMonthdAvailable()
            filterFinances = finances
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(selectedMonth.isEmpty ? "All months" : selectedMonth) {
                    Button("All months") {
                        selectedMonth = "All months"
                        filterFinances = finances
                    }
                    ForEach(months, id:\.self) { month in
                        Button(month) {
                            selectedMonth = month
                            filterFinances = finances.filter{ finance in
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MMMM yyyy"
                                let financeMonth = dateFormatter.string(from: finance.date)
                                return financeMonth == month
                            }
                        }
                    }
                }
            }
        }
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Define o estilo da data
        return dateFormatter.string(from: date)
    }
    func deleteItem(at indexSet: IndexSet) {
        // Acessar o Firestore
        let db = Firestore.firestore()
        
        indexSet.forEach { index in
            let finance = filterFinances[index] // Obter o item a ser excluído
            let financeID = finance.id // Supondo que o documento tenha um ID
            // Acessar o documento no Firestore e excluí-lo
            db.collection("finances").document(financeID!).delete { error in
                if let error = error {
                    print("Erro ao excluir o item:", error)
                } else {
                    // Remover o item da lista local
                    filterFinances.remove(at: index)
                    guard let index = filterFinances.firstIndex(where: { $0.id == finance.id }) else { return }
                    finances.remove(at: index)
                    print("Item excluído com sucesso!")
                }
            }
        }
    }
    func allMonthdAvailable() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy" // Formato do mês e ano
        
        var distinctMonthsAndYears = Set<String>()
        for date in finances.map({$0.date}){
            let monthYear = dateFormatter.string(from: date)
            distinctMonthsAndYears.insert(monthYear)
        }
        return Array(distinctMonthsAndYears)
    }

}

struct FinancialOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            FinancialOverview(finances:.constant(
                [
                    Finance(amount: 100.00, amountType: "Income", category: "Food", date: Date(), notes: "Comida", userId: "1234"),
                    Finance(amount: 100.00, amountType: "Income", category: "Food", date: Date(), notes: "Comida", userId: "1234"),
                    Finance(amount: 100.00, amountType: "Income", category: "Food", date: Date(), notes: "Comida", userId: "1234"),
                    Finance(amount: 100.00, amountType: "Income", category: "Food", date: Date(), notes: "Comida", userId: "1234"),
                ]
            ))
        }
    }
}

