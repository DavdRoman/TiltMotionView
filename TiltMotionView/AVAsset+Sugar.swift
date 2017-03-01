//
//  AVAsset+Sugar.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit
import AVFoundation

extension AVAsset {
	var thumbnail: UIImage? {
		let thumbnailGenerator = AVAssetImageGenerator(asset: self)
		thumbnailGenerator.appliesPreferredTrackTransform = true

		var time = duration
		time.value = min(time.value, 2)

		do {
			return try UIImage(cgImage: thumbnailGenerator.copyCGImage(at: time, actualTime: nil))
		} catch {
			return nil
		}
	}
}
