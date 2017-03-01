//
//  CGSize+Sugar.swift
//  TiltMotionView
//
//  Created by David Roman on 01/03/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import CoreGraphics

extension CGSize {
	var ratio: CGFloat {
		return width / height
	}
}
