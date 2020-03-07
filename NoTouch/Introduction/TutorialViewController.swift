//
//  TutorialViewController.swift
//  NoTouch
//
//  Created by Alexander Mason on 3/7/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [SlideView] {
        guard let slideOne: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as? SlideView else {
            assertionFailure("You fucked up")
            return []
        }
        
        //slideOne.textLabel.text = //Localized text
        
        guard let slideTwo: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as? SlideView else {
            assertionFailure("You fucked up")
            return []
        }
        slideTwo.textLabel.text = "Move the device closer to your face for best results."
        
        return [slideOne, slideTwo]
    }
    
    func setupSlideScrollView(slides : [SlideView]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
}

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / view.bounds.width)
    }
}
