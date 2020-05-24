//
//  NoTouchError.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

// FIXME: Change NoTouchError to NoTouchError
enum NoTouchError: Error {
    case noDeviceInput
    case inputDeviceCreationFailure
    case cameraAccessDenied
    case modelCreationFailure(Error)
    case missingModelFile
    case visionRequestFailure
    case improperDatesUsed
}
