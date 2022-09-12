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


struct Hilton: Codable {
    struct RecordDetail: Codable {
        @Firestore.IntValue
        var price: Int
        @Firestore.IntValue
        var timestamp: Int
    }
    
    @Firestore.ArrayValue
    var records:[Firestore.MapValue<RecordDetail>]
}
