//
//  Data_ext.swift
//  
//
//  Created by Алексей Лысенко on 15.04.2021.
//

import Vapor

extension Data {
    func convertToHTTPBody() -> ByteBuffer {
        return ByteBuffer(data: self)
    }
}
