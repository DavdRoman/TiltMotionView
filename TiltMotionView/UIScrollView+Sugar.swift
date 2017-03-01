//
//  UIScrollView+Sugar.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit

extension UIScrollView {
	func recenter() {
		contentOffset = CGPoint(x: (contentSize.width-frame.width)/2, y: (contentSize.height-frame.height)/2)
	}
}
