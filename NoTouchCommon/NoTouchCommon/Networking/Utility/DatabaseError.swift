//
//  DatabaseError.swift
//  NoTouchCommon
//
//  Created by Alexander Mason on 5/16/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

enum DatabaseError: Error {
    case accountRestriction
    case networkFailure // (.serverRejectedRequest)
    case authenticationFailure // go to settings and sign in (.notAuthenticated)
    case databaseError // CKError.internalError
}

// .limitExceeded <- Handle internally
// .networkFailure <- Try again with backoff timer, also monitor network reachability in general and handle things appropriately.

// TODO: Localized error messages
