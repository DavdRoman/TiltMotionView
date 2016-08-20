//
//  ViewController.swift
//  TiltMotionViewDemo
//
//  Created by David Román Aguirre on 04/01/16.
//  Copyright © 2016 David Román Aguirre. All rights reserved.
//

import UIKit
import TiltMotionView

class ViewController: UIViewController {

	@IBOutlet weak var tiltMotionView: TiltMotionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		tiltMotionView.imageView.image = UIImage(named: "photo")
	}
}
