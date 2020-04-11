/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the Vision view controller.
*/

import AVFoundation
import UIKit
import VideoToolbox
import Vision

class VisionViewController: UIViewController {
    
    @IBOutlet var coverageView: UIView!
    @IBOutlet var flashingView: UIView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var announcementLabel: UILabel!
    
    @IBOutlet var rightStackView: UIStackView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    private let alertVM = AlertViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertVM.addObserver(self)
        view.layer
    }
    
    // FIXME: Note that this is here as a model for how things were setup previously.
//    override func setupAVCapture() {
//        super.setupAVCapture()
//
//        // setup Vision parts
//        setupVision()
//
//        // start the capture
//        startCaptureSession()
//    }
    
    // MARK: - IBActions
    
    @IBAction func flipCamera(_ sender: Any) {
        // FIXME: Allow flipping of camera.
//        guard let oldPosition = devicePosition else {
//            return
//        }
//
//        let newPosition: AVCaptureDevice.Position
//
//        switch oldPosition {
//        case .front:
//            // set to back
//            newPosition = .back
//
//        case .back:
//            // set to front
//            newPosition = .front
//
//        default:
//            newPosition = .front
//            break
//        }
//
//        changeCapturePosition(position: newPosition) { result in
//            switch result {
//            case .success:
//                // Do nothing
//                break
//
//            case .failure(let error):
//                print("Error changing capture position: \(error.localizedDescription)")
//
//            }
//        }
    }
    
    @IBAction func muteUnmuteSound(_ sender: Any) {
        if alertVM.audioIsMuted {
            alertVM.audioIsMuted = false
            
            guard let image = UIImage(systemName: "speaker") else {
                return
            }
            
            // set image
            audioButton.setImage(image, for: .normal)
        } else {
            alertVM.audioIsMuted = true
            guard let image = UIImage(systemName: "speaker.slash") else {
                return
            }
            
            audioButton.setImage(image, for: .normal)
        }
    }
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            announcementLabel.isHidden = true
            coverageView.isHidden = true
            
        } else {
            coverageView.isHidden = false // animate this?
            
            announcementLabel.alpha = 0
            announcementLabel.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.announcementLabel.alpha = 1
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIView.animate(withDuration: 0.8, animations: {
                        self.announcementLabel.alpha = 0
                    }) { _ in
                        self.announcementLabel.isHidden = true
                    }
                }
            }
        }
    }
}

extension VisionViewController: AlertObserver {
    
    func startAlerting() {
        flashingView.alpha = 0
        flashingView.isHidden = false
        
        UIView.animate(withDuration: 0.1) {
            self.flashingView.alpha = 0.4
        }
    }
    
    func stopAlerting() {
        UIView.animate(withDuration: 0.1, animations: {
            self.flashingView.alpha = 0
        }) { success in
            if success {
                self.flashingView.alpha = 0
                self.flashingView.isHidden = true
            } else {
                print("No success")
            }
        }
    }
}
