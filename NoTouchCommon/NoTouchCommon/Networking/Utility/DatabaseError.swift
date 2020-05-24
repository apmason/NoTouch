//
//  DatabaseError.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public enum DatabaseError: Error {
    case networkFailure // (.serverRejectedRequest)
    case authenticationFailure // go to settings and sign in (.notAuthenticated)
    case databaseError // CKError.internalError
    case batchSaveFailed
    case unknownError(Error)
    case fatalError
}

// .limitExceeded <- Handle internally
// .networkFailure <- Try again with backoff timer, also monitor network reachability in general and handle things appropriately.

// TODO: Localized error messages
