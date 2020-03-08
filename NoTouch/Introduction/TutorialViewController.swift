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
    private let viewModel = TutorialViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    private func createSlides() -> [SlideView] {
        let slideViews = createSlideViews(withCount: 6)
        for i in 0..<slideViews.count {
            switch i {
            case 0:
                slideViews[i].textLabel.text = viewModel.placingText
                
            case 1:
                slideViews[i].textLabel.text = viewModel.moveCloserText
                
            case 2:
                slideViews[i].textLabel.text = viewModel.alertText
                
            case 3:
                slideViews[i].textLabel.text = viewModel.openText
                
            case 4:
                slideViews[i].textLabel.text = viewModel.batteryText
                
            case 5:
                slideViews[i].textLabel.text = viewModel.privacyText
                
            default:
                print("REACHED DEFAULT, SOMETHING WENT WRONG")
                assertionFailure("Default hit")
            
            }
        }
        
        return slideViews
    }
    
    private func createSlideViews(withCount count: Int) -> [SlideView] {
        var slideViews = [SlideView]()
        for _ in 0..<count {
            guard let slide: SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as? SlideView else {
                assertionFailure("Failure")
                return []
            }
            
            slideViews.append(slide)
        }
        return slideViews
    }
    
    private func setupSlideScrollView(slides : [SlideView]) {
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
