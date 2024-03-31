//
//  Finance.swift
//  FinControl
//
//  Created by Lucas Castro on 30/03/24.
//

import Foundation
import FirebaseFirestore

struct Finance: Codable, Identifiable{
    @DocumentID var id: String?
    var amount: Double
    var amountType: String
    var category: String
    var date: Date
    var notes: String
    var userId: String
}
