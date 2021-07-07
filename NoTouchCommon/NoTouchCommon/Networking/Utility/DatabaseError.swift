//
//  DatabaseError.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public enum DatabaseError: Error {
    case networkFailure
    case authenticationFailure
    case databaseError
    case batchSaveFailed
    case unknownError(Error)
    case fatalError
}
