//
//  QRCodeEyeStyleSquare.swift
//
//  Created by Darren Ford on 17/11/21.
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import CoreGraphics
import Foundation

public extension QRCode.EyeShape {
	/// A 'rounded rect with a pointy bit facing inwards' style eye design
	@objc(QRCodeEyeStyleSquare) class Square: NSObject, QRCodeEyeShapeGenerator {
		@objc public static let Name = "square"
		@objc public static func Create(_ settings: [String: Any]?) -> QRCodeEyeShapeGenerator {
			return QRCode.EyeShape.Square()
		}

		@objc public func settings() -> [String: Any] { return [:] }

		public func copyShape() -> QRCodeEyeShapeGenerator {
			return Self.Create(self.settings())
		}

		public func eyePath() -> CGPath {
			let squareEyePath = CGMutablePath()
			squareEyePath.move(to: CGPoint(x: 70, y: 70))
			squareEyePath.line(to: CGPoint(x: 20, y: 70))
			squareEyePath.line(to: CGPoint(x: 20, y: 20))
			squareEyePath.line(to: CGPoint(x: 70, y: 20))
			squareEyePath.line(to: CGPoint(x: 70, y: 70))
			squareEyePath.close()
			squareEyePath.move(to: CGPoint(x: 80, y: 80))
			squareEyePath.curve(to: CGPoint(x: 80, y: 10), controlPoint1: CGPoint(x: 80, y: 80), controlPoint2: CGPoint(x: 80, y: 10))
			squareEyePath.line(to: CGPoint(x: 10, y: 10))
			squareEyePath.line(to: CGPoint(x: 10, y: 80))
			squareEyePath.line(to: CGPoint(x: 80, y: 80))
			squareEyePath.line(to: CGPoint(x: 80, y: 80))
			squareEyePath.close()
			return squareEyePath
		}

		public func pupilPath() -> CGPath {
			return CGPath(rect: CGRect(x: 30, y: 30, width: 30, height: 30), transform: nil)
		}
	}
}
