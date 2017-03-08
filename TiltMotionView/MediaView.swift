//
//  MediaView.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit

final class MediaView: UIView {

	var media: Media? {
		didSet { mediaDidChange() }
	}

	let imageView = UIImageView()
	let videoView = VideoPlayerView()

	dynamic var videoPlayer: VideoPlayer? {
		get { return videoView.playerLayer.player as? VideoPlayer }
		set {
			willChangeValue(forKey: #keyPath(videoPlayer))
			videoView.playerLayer.player = newValue
			didChangeValue(forKey: #keyPath(videoPlayer))
		}
	}

	init(media: Media? = nil) {
		self.media = media
		super.init(frame: .zero)
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		mediaDidChange()
		addObserver(self, forKeyPath: #keyPath(videoPlayer.isPlaying), options: [.initial, .new], context: nil)
	}

	func mediaDidChange() {
		[imageView, videoView].forEach { $0.removeFromSuperview() }

		if let media = media {
			switch media {
			case .photo(let image):
				videoPlayer = nil
				setUpImageView(with: image)
			case .video(let url):
				setUpVideoView(with: url)
			}
		}
	}

	func setUpImageView(with image: UIImage) {
		addSubview(imageView)

		imageView.image = image
		imageView.pinToSuperview()
		imageView.constrainImageAspectRatio()
	}

	func setUpVideoView(with url: URL) {
		videoPlayer = VideoPlayer(url: url)

		if let thumbnail = videoPlayer?.currentItem?.asset.thumbnail {
			setUpImageView(with: thumbnail)
		}

		addSubview(videoView)
		videoView.pinToSuperview()
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == #keyPath(videoPlayer.isPlaying) {
			guard let isPlaying = change?[.newKey] as? Bool else {
				return
			}

			UIView.animate(withDuration: isPlaying ? 0 : 0.25) {
				self.videoView.alpha = isPlaying || self.videoPlayer?.progress != 1 ? 1 : 0
				self.imageView.alpha = !isPlaying && (self.videoPlayer?.progress == 0 || self.videoPlayer?.progress == 1) ? 1 : 0
			}
		}
	}

	var size: CGSize? {
		return imageView.image?.size
	}

	@available(*, unavailable) required init?(coder aDecoder: NSCoder) { fatalError() }
}
