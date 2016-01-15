//
//  TiltMotionView.swift
//  TiltMotionView
//
//  Created by David Román Aguirre on 04/01/16.
//  Copyright © 2016 David Román Aguirre. All rights reserved.
//

import UIKit
import CoreMotion

let TiltMotionRotationMinimumTreshold: CGFloat = 0.25
let TiltMotionGyroUpdateInterval: CGFloat = 1 / 500
let TiltMotionRotationFactor: CGFloat = 15

enum TiltMotionViewRatio {
    case None
    case Horizontal
    case Vertical
}

public class TiltMotionView: UIScrollView, UIScrollViewDelegate {
    
    private let motionManager = CMMotionManager()
    private var maximumOffset: CGFloat {
        switch self.ratio {
        case .Horizontal:
            return self.contentSize.width - self.frame.size.width
        case .Vertical:
            return self.contentSize.height - self.frame.size.height
        case .None:
            return 0
        }
    }
    private var ratio: TiltMotionViewRatio {
        if let imageSize = self.imageView.image?.size {
            if imageSize.width/imageSize.height > self.frame.size.width/self.frame.size.height {
                return .Horizontal
            }
            
            return .Vertical
        }
        
        return .None
    }
    
    public let imageView = UIImageView()
    public var motionEnabled = true { didSet { motionEnabledDidChange() } }
    
    func motionEnabledDidChange() {
        if self.motionEnabled {
            self.startMonitoring()
        } else {
            self.motionManager.stopGyroUpdates()
        }
    }
    
    public init() {
        super.init(frame: CGRectZero)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.addObserver(self, forKeyPath: "image", options: [.Initial, .New], context: nil)
        self.addSubview(self.imageView)
        
        // MARK: workaround until didSet can get called during init (or at least for provided default values)
        self.motionEnabledDidChange()
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public override func layoutSubviews() {
        self.resize()
        super.layoutSubviews()
    }
    
    private func resize() {
        UIView.performWithoutAnimation {
            if let imageSize = self.imageView.image?.size {
                let proportion = max(self.frame.size.width/imageSize.width, self.frame.size.height/imageSize.height)
                let newSize = CGSizeMake(imageSize.width*proportion, imageSize.height*proportion)
                
                if self.contentSize != newSize {
                    self.contentSize = newSize
                }
            }
            
            self.imageView.frame = self.frame
            self.imageView.center = CGPointMake(self.contentSize.width/2, self.contentSize.height/2)
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.resize()
    }
    
    private func startMonitoring() {
        if !self.motionManager.gyroActive && self.motionManager.gyroAvailable {
            self.motionManager.startGyroUpdatesToQueue(.mainQueue()) { [unowned self] gyroData, error in
                if self.ratio != .None && error == nil {
                    if let gyroData = gyroData {
                        let rotationRate = self.rotationRateForCurrentOrientationFromGyroData(gyroData)
                        
                        if (fabs(rotationRate) >= TiltMotionRotationMinimumTreshold) {
                            var newOffset: CGPoint!
                            
                            switch self.ratio {
                            case .Horizontal:
                                newOffset = CGPointMake(max(min(self.contentOffset.x - rotationRate * TiltMotionRotationFactor, self.maximumOffset), 0), 0)
                            case .Vertical:
                                newOffset = CGPointMake(0, max(min(self.contentOffset.y - rotationRate * TiltMotionRotationFactor, self.maximumOffset), 0))
                            case .None:
                                fatalError("Dafuq happened here? This CAN'T be .None")
                            }
                            
                            UIView.animateWithDuration(0.3, delay: 0, options: [.BeginFromCurrentState, .AllowUserInteraction, .CurveEaseOut], animations: {
                                self.contentOffset = newOffset
                                }, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func rotationRateForCurrentOrientationFromGyroData(gyroData: CMGyroData) -> CGFloat {
        var rotationRate: CGFloat = 0
        
        switch (UIApplication.sharedApplication().statusBarOrientation) {
        case .Portrait:
            rotationRate = CGFloat(gyroData.rotationRate.y)
            
        case .PortraitUpsideDown:
            rotationRate = CGFloat(-gyroData.rotationRate.y)
            
        case .LandscapeLeft:
            rotationRate = CGFloat(gyroData.rotationRate.y)
            
        case .LandscapeRight:
            rotationRate = CGFloat(-gyroData.rotationRate.y)
            
        default:
            break;
        }
        
        return rotationRate
    }
    
    deinit {
        self.imageView.removeObserver(self, forKeyPath: "image")
    }
}
