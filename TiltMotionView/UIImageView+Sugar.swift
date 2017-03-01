//
//  UIImageView+Sugar.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit

extension UIImageView {
	func constrainImageAspectRatio() {
		guard let image = image else {
			return
		}

		removeConstraints(constraints)
		widthAnchor.constraint(equalTo: heightAnchor, multiplier: image.size.ratio).isActive = true
	}
}
