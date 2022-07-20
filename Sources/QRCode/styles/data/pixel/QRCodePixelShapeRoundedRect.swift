//
//  QRCodePixelShapeRoundedRect.swift
//
//  Created by Darren Ford on 3/5/22.
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

public extension QRCode.PixelShape {
	/// A rounded rect pixel shape
	@objc(QRCodePixelShapeRoundedRect) class RoundedRect: NSObject, QRCodePixelShapeGenerator {
		public static var Name: String { "roundedRect" }
		private let common: CommonPixelGenerator

		/// Create
		/// - Parameters:
		///   - inset: The inset between each pixel
		///   - cornerRadiusFraction: For types that support it, the roundedness of the corners (0 -> 1)
		@objc public init(inset: CGFloat = 0, cornerRadiusFraction: CGFloat = 0) {
			self.common = CommonPixelGenerator(pixelType: .roundedRect, inset: inset, cornerRadiusFraction: cornerRadiusFraction)
			super.init()
		}

		public static func Create(_ settings: [String: Any]?) -> QRCodePixelShapeGenerator {
			let inset = DoubleValue(settings?["inset", default: 0]) ?? 0
			let radius = DoubleValue(settings?["cornerRadiusFraction"]) ?? 0
			return RoundedRect(inset: inset, cornerRadiusFraction: radius)
		}

		public func copyShape() -> QRCodePixelShapeGenerator {
			return RoundedRect(inset: self.common.inset, cornerRadiusFraction: self.common.cornerRadiusFraction)
		}

		public func onPath(size: CGSize, data: QRCode, isTemplate: Bool) -> CGPath {
			self.common.onPath(size: size, data: data, isTemplate: isTemplate)
		}

		public func offPath(size: CGSize, data: QRCode, isTemplate: Bool) -> CGPath {
			self.common.offPath(size: size, data: data, isTemplate: isTemplate)
		}

		@objc public var cornerRadiusFraction: CGFloat { self.common.cornerRadiusFraction }
		@objc public var inset: CGFloat { self.common.inset }

		public func settings() -> [String: Any] {
			return [
				"inset": self.common.inset,
				"cornerRadiusFraction": self.common.cornerRadiusFraction,
			]
		}
	}
}
