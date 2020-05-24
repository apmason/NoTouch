//
//  UserSettings.swift
//  HandsOff
//
//  Created by Alexander Mason on 4/18/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import Foundation

public class UserSettings: ObservableObject {
    @Published public var muteSound = false
    @Published public var hideCameraFeed = false
    @Published public var pauseDetection = false
    @Published public var cameraAuthState: CameraAuthModel.CameraAuthState = .notDetermined
    @Published public var recordHolder = RecordHolder()
    @Published public var networkTracker = NetworkStateTracker()
    
    public init() {}
}
