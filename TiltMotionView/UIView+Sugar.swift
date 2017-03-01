//
//  UIView+Sugar.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit

extension UIView {
	enum PinningStrategy {
		case edges
		case verticals
		case horizontals
		case sizeAndCenters

		var attributes: [NSLayoutAttribute] {
			switch self {
			case .edges:
				return [.top, .left, .right, .bottom]
			case .verticals:
				return [.left, .right, .centerY, .height]
			case .horizontals:
				return [.top, .bottom, .centerX, .width]
			case .sizeAndCenters:
				return [.width, .height, .centerX, .centerY]
			}
		}
	}

	func pinToSuperview(strategy: PinningStrategy = .edges) {
		guard let superview = superview else {
			return
		}

		translatesAutoresizingMaskIntoConstraints = false
		superview.addConstraints(strategy.attributes.map {
			NSLayoutConstraint(item: self, attribute: $0, relatedBy: .equal, toItem: superview, attribute: $0, multiplier: 1, constant: 0)
		})
	}
}
