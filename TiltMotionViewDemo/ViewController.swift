//
//  ViewController.swift
//  TiltMotionViewDemo
//
//  Created by David Román Aguirre on 04/01/16.
//  Copyright © 2016 David Román Aguirre. All rights reserved.
//

import UIKit
import TiltMotionView

final class ViewController: UIViewController {

	private enum Constants {
		static let photoUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "photo", ofType: "jpg")!)
		static let videoUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "video", ofType: "mp4")!)
	}

	let tiltMotionView = TiltMotionView(media: .photo(Constants.photoUrl))

	override func viewDidLoad() {
		view.addSubview(tiltMotionView)
		tiltMotionView.pinToSuperview()

		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
	}

	func handleTap() {
		if let isPlaying = tiltMotionView.videoPlayer?.isPlaying {
			(isPlaying ? tiltMotionView.videoPlayer?.pause : tiltMotionView.videoPlayer?.play)?()
		}
	}

	override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake, let media = tiltMotionView.media {
			switch media {
			case .photo:
				tiltMotionView.media = .video(Constants.videoUrl)
			case .video:
				tiltMotionView.media = .photo(Constants.photoUrl)
			}
		}
	}
}
