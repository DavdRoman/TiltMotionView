//
//  TiltMotionView.swift
//  TiltMotionView
//
//  Created by David Román Aguirre on 04/01/16.
//  Copyright © 2016 David Román Aguirre. All rights reserved.
//

import UIKit
import AVFoundation

public final class TiltMotionView: UIScrollView, UIScrollViewDelegate {

	public dynamic var isMotionEnabled = true
	public dynamic static var isMotionEnabled: Bool {
		get {
			return Gyro.shared.isEnabled
		}
		set {
			Gyro.shared.isEnabled = newValue
		}
	}

	let mediaView: MediaView

	public dynamic var videoPlayer: VideoPlayer? { return mediaView.videoPlayer }

	public var media: Media? {
		get { return mediaView.media }
		set {
			mediaView.media = newValue
			reconstraintMediaView()
		}
	}

	public init(media: Media? = nil) {
		mediaView = MediaView(media: media)

		super.init(frame: .zero)

		showsHorizontalScrollIndicator = false
		showsVerticalScrollIndicator = false
		isScrollEnabled = false

		reconstraintMediaView()
		startMonitoring()
	}

	func reconstraintMediaView() {
		guard let ratio = mediaView.size?.ratio else {
			return
		}

		mediaView.removeFromSuperview()
		addSubview(mediaView)
		mediaView.pinToSuperview(strategy: ratio > frame.size.ratio ? .verticals : .horizontals)
		recenterIfNeeded()
	}

	public override func layoutSubviews() {
		reconstraintMediaView()
		super.layoutSubviews()
	}

	private var previousFrame: CGRect?

	func recenterIfNeeded() {
		if previousFrame != frame, let size = mediaView.size {
			let newRatio = max(frame.size.width / size.width, frame.size.height / size.height)
			let newContentSize = CGSize(width: size.width * newRatio, height: size.height * newRatio)

			contentSize = newContentSize
			contentOffset = CGPoint(x: (newContentSize.width - frame.width) / 2, y: (newContentSize.height - frame.height) / 2)
			previousFrame = frame
		}
	}

	// MARK: Motion

	private enum AspectRatio {
		case portrait
		case landscape
	}

	private enum Constants {
		static let rotationFactor: CGFloat = 15
	}

	private var aspectRatio: AspectRatio {
		guard let ratio = mediaView.size?.ratio else {
			return .portrait
		}

		return ratio > frame.size.ratio ? .portrait : .landscape
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
		Gyro.shared.didUpdateClosure = { [weak self] rate in
			guard
				let `self` = self,
				self.isMotionEnabled,
				self.media != nil
			else {
				return
			}

			let newOffset: CGPoint

			switch self.aspectRatio {
			case .portrait:
				newOffset = CGPoint(x: max(min(self.contentOffset.x - rate * Constants.rotationFactor, self.maximumOffset), 0), y: 0)
			case .landscape:
				newOffset = CGPoint(x: 0, y: max(min(self.contentOffset.y - rate * Constants.rotationFactor, self.maximumOffset), 0))
			}

			UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: {
				self.contentOffset = newOffset
			}, completion: nil)
		}
	}

	@available(*, unavailable) required public init?(coder aDecoder: NSCoder) { fatalError() }
}
