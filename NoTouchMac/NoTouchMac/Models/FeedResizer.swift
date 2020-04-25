//
//  FeedResizer.swift
//  NoTouchMac
//
//  Created by Alexander Mason on 4/19/20.
//  Copyright © 2020 Canopy Interactive. All rights reserved.
//

import NoTouchCommon
import Foundation

/// A class that observes notifications for the resizing of windows, and will resize a `VideoFeed`'s previewLayer accordingly.
class FeedResizer {
    
    let feed: VideoFeed
    
    init(_ feed: VideoFeed) {
        self.feed = feed
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowWillResize(_:)),
                                               name: .windowWillResize,
                                               object: nil)
    }
    
    @objc func windowWillResize(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: CGFloat],
            let height = userInfo["height"],
            let width = userInfo["width"]
            else {
                return
        }
        
        let newRect = CGRect(x: 0, y: 0, width: width, height: height)
        feed.updatePreviewLayerFrame(to: newRect)
    }
}
