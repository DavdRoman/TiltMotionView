//
//  TiltMotionView.swift
//  TiltMotionView
//
//  Created by David Román Aguirre on 04/01/16.
//  Copyright © 2016 David Román Aguirre. All rights reserved.
//

import UIKit
import CoreMotion

public class TiltMotionView: UIScrollView, UIScrollViewDelegate {

	public dynamic var motionEnabled = true {
		didSet {
			motionEnabledDidChange()
		}
	}

	public dynamic let imageView = UIImageView()

	public init() {
		super.init(frame: .zero)
		initialize()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	private func initialize() {
		showsHorizontalScrollIndicator = false
		showsVerticalScrollIndicator = false
		scrollEnabled = false

		imageView.contentMode = .ScaleAspectFill
		imageView.addObserver(self, forKeyPath: "image", options: [.Initial, .New], context: nil)
		addSubview(imageView)

		motionEnabledDidChange() // MARK: workaround until didSet can get called during init (or at least for provided default values)
	}

	// MARK: resizing

	public override func layoutSubviews() {
		resize()
		super.layoutSubviews()
	}

	public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		resize(force: true)
	}

	private var previousFrame = CGRect.zero

	private func resize(force force: Bool = false) {
		if let imageSize = imageView.image?.size where force || frame != previousFrame {
			let ratio = max(frame.size.width/imageSize.width, frame.size.height/imageSize.height)
			let newContentSize = CGSize(width: imageSize.width*ratio, height: imageSize.height*ratio)

			contentSize = newContentSize
			contentOffset = CGPoint(x: newContentSize.width/2-frame.width/2, y: newContentSize.height/2-frame.height/2)
			imageView.frame = frame
			imageView.center = CGPoint(x: contentSize.width/2, y: contentSize.height/2)
			previousFrame = frame
		}
	}

	// MARK: Motion

	private enum AspectRatio {
		case Portrait
		case Landscape
	}

	private static let RotationMinimumThreshold = CGFloat(0.25)
	private static let GyroUpdateInterval = CGFloat(1 / 500)
	private static let RotationFactor = CGFloat(15)

	private let motionManager = CMMotionManager()

	private func motionEnabledDidChange() {
		(motionEnabled ? startMonitoring : motionManager.stopGyroUpdates)()
	}

	private var aspectRatio: AspectRatio {
		guard let imageSize = imageView.image?.size else { return .Portrait }
		return imageSize.width/imageSize.height > frame.width/frame.height ? .Portrait : .Landscape
	}

	private var maximumOffset: CGFloat {
		switch aspectRatio {
		case .Portrait:
			return contentSize.width - frame.width
		case .Landscape:
			return contentSize.height - frame.height
		}
	}

	private func startMonitoring() {
		if !motionManager.gyroActive && motionManager.gyroAvailable {
			motionManager.startGyroUpdatesToQueue(.mainQueue()) { [unowned self] gyroData, error in
				if let gyroData = gyroData where error == nil {
					let rotationRate = self.rotationRateForCurrentOrientation(with: gyroData)

					if (fabs(rotationRate) >= TiltMotionView.RotationMinimumThreshold) {
						var newOffset = CGPoint()

						switch self.aspectRatio {
						case .Portrait:
							newOffset = CGPointMake(max(min(self.contentOffset.x - rotationRate * TiltMotionView.RotationFactor, self.maximumOffset), 0), 0)
						case .Landscape:
							newOffset = CGPointMake(0, max(min(self.contentOffset.y - rotationRate * TiltMotionView.RotationFactor, self.maximumOffset), 0))
						}

						UIView.animateWithDuration(0.3, delay: 0, options: [.BeginFromCurrentState, .AllowUserInteraction, .CurveEaseOut], animations: {
							self.contentOffset = newOffset
						}, completion: nil)
					}
				}
			}
		}
	}

	private func rotationRateForCurrentOrientation(with gyroData: CMGyroData) -> CGFloat {
		var rotationRate = CGFloat()

		switch (UIApplication.sharedApplication().statusBarOrientation) {
		case .Portrait, .LandscapeLeft:
			rotationRate = CGFloat(gyroData.rotationRate.y)

		case .PortraitUpsideDown, .LandscapeRight:
			rotationRate = CGFloat(-gyroData.rotationRate.y)

		default:
			break
		}

		return rotationRate
	}

	deinit {
		imageView.removeObserver(self, forKeyPath: "image")
	}
}
