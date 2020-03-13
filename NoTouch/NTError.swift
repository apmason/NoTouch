//
//  NTError.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/8/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

enum NTError: Error {
    case noDeviceInput
    case inputDeviceCreationFailure
    case cameraAccessDenied
}
