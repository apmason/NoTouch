//
//  NetworkingConstants.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/2/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

enum RecordType: String {
    case touch = "Touch"
}

internal struct NetworkingConstants {    
    /// The date format that all data sent to the server is in.
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss zzz"
}
