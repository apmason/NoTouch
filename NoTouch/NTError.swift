//
//  NTError.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

// FIXME: Change NTError to NoTouchError
enum NTError: Error {
    case noDeviceInput
    case inputDeviceCreationFailure
    case cameraAccessDenied
    case modelCreationFailure(Error)
    case missingModelFile
    case visionRequestFailure
}
