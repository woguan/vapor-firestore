//
//  AllTypesModelTest.swift
//  
//
//  Created by Алексей Лысенко on 25.04.2021.
//

import Foundation
import VaporFirestore

struct AllTypesModelTest: Codable {
    struct NestedType: Codable {
        @Firestore.StringValue
        var nestedString: String
    }
    
    @Firestore.StringValue
    var someStringValue: String
    
    @Firestore.BoolValue
    var someBoolValue: Bool
    
    @Firestore.IntValue
    var someIntValue: Int
    
    @Firestore.DoubleValue
    var someDoubleValue: Double
    
    var someGeoPoint: Firestore.GeoPoint
    
    @Firestore.TimestampValue
    var someTimestamp: Date
    
    var someReference: Firestore.ReferenceValue
    
    @Firestore.MapValue
    var someMapValue: NestedType
    
    @Firestore.ArrayValue
    var someArray: [Firestore.StringValue]
}
