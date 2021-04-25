//
//  TestFields.swift
//  
//
//  Created by Алексей Лысенко on 16.04.2021.
//

import VaporFirestore

struct TestFields: Codable {
    @Firestore.StringValue
    var title: String
    @Firestore.StringValue
    var subTitle: String
}
