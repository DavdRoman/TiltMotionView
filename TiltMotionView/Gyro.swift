//
//  Gyro.swift
//  TiltMotionView
//
//  Created by David Roman on 27/04/2017.
//  Copyright © 2017 David Román Aguirre. All rights reserved.
//

import UIKit
import CoreMotion

final class Gyro {
	static let shared = Gyro()

	typealias GyroClosure = ((CGFloat) -> Void)

	private enum Constants {
		static let rotationMinimumThreshold: CGFloat = 0.25
		static let gyroUpdateInterval: CGFloat = 0.002
	}

	private let motionManager = CMMotionManager()
	var didUpdateClosure: GyroClosure? {
		get {
			return nil
		}
		set {
			guard let closure = newValue else {
				return
			}
			listeners.append(closure)
		}
	}
	private var listeners: [GyroClosure] = []
	var isEnabled: Bool = true

	private init() {
		startMonitoring()
	}

	private func startMonitoring() {
		if !motionManager.isGyroActive && motionManager.isGyroAvailable {
			motionManager.startGyroUpdates(to: .main) { [weak self] gyroData, error in
				guard
					let `self` = self,
					self.isEnabled,
					let gyroData = gyroData,
					error == nil
					else {
						return
				}

				let rotationRate = self.rotationRateForCurrentOrientation(with: gyroData)

				if (fabs(rotationRate) >= Constants.rotationMinimumThreshold) {
					self.listeners.forEach {
						$0(rotationRate)
					}
				}
			}
		}
	}

	private func rotationRateForCurrentOrientation(with gyroData: CMGyroData) -> CGFloat {
		var rotationRate = CGFloat()

		switch UIApplication.shared.statusBarOrientation {
		case .portrait, .landscapeLeft:
			rotationRate = CGFloat(gyroData.rotationRate.y)

		case .portraitUpsideDown, .landscapeRight:
			rotationRate = CGFloat(-gyroData.rotationRate.y)

		default:
			break
		}

		return rotationRate
	}
}
