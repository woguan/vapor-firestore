//
//  NullValueTest.swift
//  
//
//  Created by Алексей Лысенко on 16.04.2021.
//

import VaporFirestore

struct NullValueTest: Codable {
    @Firestore.NullableValue<Firestore.StringValue>
    var title: String?
    @Firestore.NullableValue<Firestore.IntValue>
    var number: Int?
}
