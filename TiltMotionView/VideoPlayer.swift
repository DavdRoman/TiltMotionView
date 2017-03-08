//
//  VideoPlayer.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import AVFoundation

public final class VideoPlayer: AVPlayer {

	public dynamic var isPlaying = false
	public dynamic var progress = 0.0
	public dynamic var progressString = "00:00"

	public override init() {
		super.init()
		initialize()
	}

	public override init(url URL: URL) {
		super.init(url: URL)
		initialize()
	}

	public override init(playerItem item: AVPlayerItem?) {
		super.init(playerItem: item)
		initialize()
	}

	func initialize() {
		addObserver(self, forKeyPath: #keyPath(rate), options: [.initial, .new, .old], context: nil)

		addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: .main) { time in
			if let totalDuration = self.currentItem?.duration.seconds {
				self.progress = time.seconds / totalDuration
			}

			// TODO: improve (use NSDateComponentsFormatter?)
			let seconds = Int(floor(time.seconds).truncatingRemainder(dividingBy: 60))
			let minutes = Int(floor(time.seconds) / 60)

			let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
			let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"

			self.progressString = "\(minutesString):\(secondsString)"
		}
	}

	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == #keyPath(rate) {
			guard let newIsPlayingFloat = change?[.newKey] as? Float else {
				return
			}

			let newIsPlaying = newIsPlayingFloat != 0

			let oldIsPlayingFloat = change?[.oldKey] as? Float
			let oldIsPlaying = oldIsPlayingFloat != 0

			if newIsPlaying != oldIsPlaying {
				isPlaying = newIsPlaying
			}
		}
	}

	public override func play() {
		if progress == 1 {
			seek(to: kCMTimeZero)
			super.play()
		} else {
			super.play()
		}
	}
}
