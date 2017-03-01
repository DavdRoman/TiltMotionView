//
//  VideoPlayerView.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoPlayerView: UIView {

	let playerLayer = AVPlayerLayer()

	init() {
		super.init(frame: .zero)
		layer.addSublayer(playerLayer)
	}

	override func layoutSubviews() {
		playerLayer.frame = bounds
		super.layoutSubviews()
	}

	@available(*, unavailable) required init?(coder aDecoder: NSCoder) { fatalError() }
}
