//
//  TiltMotionView.swift
//  TiltMotionView
//
//  Created by David Román Aguirre on 04/01/16.
//  Copyright © 2016 David Román Aguirre. All rights reserved.
//

import UIKit
import CoreMotion

public final class TiltMotionView: UIScrollView, UIScrollViewDelegate {

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
		isScrollEnabled = false

		imageView.contentMode = .scaleAspectFill
		imageView.addObserver(self, forKeyPath: "image", options: [.initial, .new], context: nil)
		addSubview(imageView)

		motionEnabledDidChange() // MARK: workaround until didSet can get called during init (or at least for provided default values)
	}

	// MARK: resizing

	open override func layoutSubviews() {
		resize()
		super.layoutSubviews()
	}

	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		resize(force: true)
	}

	private var previousFrame = CGRect.zero

	private func resize(force: Bool = false) {
		if imageView.frame.size == .zero {
			imageView.frame = frame
		}

		if let imageSize = imageView.image?.size, force || frame != previousFrame {
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
		case portrait
		case landscape
	}

	private static let RotationMinimumThreshold = CGFloat(0.25)
	private static let GyroUpdateInterval = CGFloat(1 / 500)
	private static let RotationFactor = CGFloat(15)

	private let motionManager = CMMotionManager()

	private func motionEnabledDidChange() {
		(motionEnabled ? startMonitoring : motionManager.stopGyroUpdates)()
	}

	private var aspectRatio: AspectRatio {
		guard let imageSize = imageView.image?.size else { return .portrait }
		return imageSize.width/imageSize.height > frame.width/frame.height ? .portrait : .landscape
	}

	private var maximumOffset: CGFloat {
		switch aspectRatio {
		case .portrait:
			return contentSize.width - frame.width
		case .landscape:
			return contentSize.height - frame.height
		}
	}

	private func startMonitoring() {
		if !motionManager.isGyroActive && motionManager.isGyroAvailable {
			motionManager.startGyroUpdates(to: .main) { [unowned self] gyroData, error in
				if let gyroData = gyroData, error == nil {
					let rotationRate = self.rotationRateForCurrentOrientation(with: gyroData)

					if (fabs(rotationRate) >= TiltMotionView.RotationMinimumThreshold) {
						var newOffset = CGPoint()

						switch self.aspectRatio {
						case .portrait:
							newOffset = CGPoint(x: max(min(self.contentOffset.x - rotationRate * TiltMotionView.RotationFactor, self.maximumOffset), 0), y: 0)
						case .landscape:
							newOffset = CGPoint(x: 0, y: max(min(self.contentOffset.y - rotationRate * TiltMotionView.RotationFactor, self.maximumOffset), 0))
						}

						UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: {
							self.contentOffset = newOffset
						}, completion: nil)
					}
				}
			}
		}
	}

	private func rotationRateForCurrentOrientation(with gyroData: CMGyroData) -> CGFloat {
		var rotationRate = CGFloat()

		switch (UIApplication.shared.statusBarOrientation) {
		case .portrait, .landscapeLeft:
			rotationRate = CGFloat(gyroData.rotationRate.y)

		case .portraitUpsideDown, .landscapeRight:
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
