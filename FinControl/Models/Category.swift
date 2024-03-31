//
//  Category.swift
//  FinControl
//
//  Created by Lucas Castro on 27/03/24.
//

import Foundation
import FirebaseFirestore

struct Category: Identifiable, Codable {
    @DocumentID var id: String?
    var category: String
    var userId: String
}
