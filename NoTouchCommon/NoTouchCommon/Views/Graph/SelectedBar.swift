//
//  SelectedBar.swift
//  NoTouchCommon
//
//  Created by Alex Mason on 7/7/21.
//  Copyright © 2021 Canopy Interactive. All rights reserved.
//

import Combine
import CoreGraphics

class SelectedBar {
    let barIndex: Int
    let barWidth: CGFloat
    @Published var hourlyData: HourlyData
    let userSettings: UserSettings
    
    private var cancellableObservation: AnyCancellable?
        
    init(barIndex: Int, barWidth: CGFloat, hourlyData: HourlyData, userSettings: UserSettings) {
        self.barIndex = barIndex
        self.barWidth = barWidth
        self.hourlyData = hourlyData
        self.userSettings = userSettings
        
        setupObserver()
    }
    
    func setupObserver() {
        self.cancellableObservation = userSettings.$recordHolder.sink(receiveValue: { [weak self] recordHolder in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                
                // Get day's current hour
                let currentHour = Calendar.current.component(.hour, from: Date())
                
                // Latest date is selected, update data.
                if self.barIndex == currentHour {
                    self.hourlyData = self.userSettings.recordHolder.hourlyData[self.barIndex]
                }
            }
        })
    }
}
