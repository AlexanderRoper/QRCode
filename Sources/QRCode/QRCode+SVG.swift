//
//  QRCode+SVG.swift
//
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

import Foundation
import CoreGraphics
import ImageIO

// QRCode SVG representation

public extension QRCode {
	/// Returns a string of SVG code for an image depicting this QR Code, with the given number of border modules.
	/// - Parameters:
	///   - dimension: The dimension of the output svg
	///   - design: The design for the QR Code
	///   - logoTemplate: The logo template to use when generating the svg data
	/// - Returns: An SVG representation of the QR code
	///
	/// The string always uses Unix newlines (\n), regardless of the platform.
	@objc func svg(
		dimension: Int,
		design: QRCode.Design,
		logoTemplate: QRCode.LogoTemplate? = nil
	) -> String {
		let sz = CGSize(dimension: dimension)
		var svg = ""

		// SVG Header
		svg += "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlnsXlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" height=\"\(dimension)\" width=\"\(dimension)\">\n"

		var pathDefinitions: [String] = []

		// The background color for the qr code

		if let background = design.style.background,
			let backgroundFill = background.svgRepresentation(styleIdentifier: "background")
		{
			svg += "   <rect \(backgroundFill.styleAttribute) x=\"0\" y=\"0\" width=\"\(dimension)\" height=\"\(dimension)\" />\n"

			if let def = backgroundFill.styleDefinition {
				pathDefinitions.append(def)
			}
		}

		// If negatedOnPixelsOnly, superceed all other styles and display settings
		if design.shape.negatedOnPixelsOnly {
			var negatedMatrix = self.boolMatrix.inverted()
			if let logoTemplate = logoTemplate {
				negatedMatrix = logoTemplate.applyingMask(matrix: negatedMatrix, dimension: CGFloat(dimension))
			}
			let negatedPath = design.shape.onPixels.generatePath(from: negatedMatrix, size: sz)
			if let onPixels = design.style.onPixels.svgRepresentation(styleIdentifier: "on-pixels") {
				svg += "   <path \(onPixels.styleAttribute) d=\"\(negatedPath.svgDataPath())\" />\n"
				if let def = onPixels.styleDefinition {
					pathDefinitions.append(def)
				}
			}
		}
		else {

			// Eye background color

			if let eyeBackgroundColor = design.style.eyeBackground,
				let hexEyeBackgroundColor = design.style.eyeBackground?.hexRGBCode()
			{
				let eyeBackgroundPath = self.path(sz, components: .eyeBackground, shape: design.shape)
				svg += "   <path fill=\"\(hexEyeBackgroundColor)\" fill-opacity=\"\(eyeBackgroundColor.alpha)\" d=\"\(eyeBackgroundPath.svgDataPath()))\" />\n"
			}

			// Pupil

			do {
				let eyePupilPath = self.path(sz, components: .eyePupil, shape: design.shape)
				if let pupilFill = design.style.actualPupilStyle.svgRepresentation(styleIdentifier: "pupil-fill") {
					svg += "   <path \(pupilFill.styleAttribute) d=\"\(eyePupilPath.svgDataPath())\" />\n"
					if let def = pupilFill.styleDefinition {
						pathDefinitions.append(def)
					}
				}
			}

			// Eye

			do {
				let eyeOuterPath = self.path(sz, components: .eyeOuter, shape: design.shape)
				if let eyeOuterFill = design.style.actualEyeStyle.svgRepresentation(styleIdentifier: "eye-outer-fill") {
					svg += "   <path \(eyeOuterFill.styleAttribute) d=\"\(eyeOuterPath.svgDataPath())\" />\n"
					if let def = eyeOuterFill.styleDefinition {
						pathDefinitions.append(def)
					}
				}
			}

			// Off pixels

			do {
				if let _ = design.shape.offPixels {
					let offPixelsPath = self.path(sz, components: .offPixels, shape: design.shape, logoTemplate: logoTemplate)
					if let offPixels = design.style.offPixels?.svgRepresentation(styleIdentifier: "off-pixels") {
						svg += "   <path \(offPixels.styleAttribute) d=\"\(offPixelsPath.svgDataPath())\" />\n"
						if let def = offPixels.styleDefinition {
							pathDefinitions.append(def)
						}
					}
				}
			}

			// On pixels

			do {
				let onPixelsPath = self.path(sz, components: .onPixels, shape: design.shape, logoTemplate: logoTemplate)
				if let onPixels = design.style.onPixels.svgRepresentation(styleIdentifier: "on-pixels") {
					svg += "   <path \(onPixels.styleAttribute) d=\"\(onPixelsPath.svgDataPath())\" />\n"
					if let def = onPixels.styleDefinition {
						pathDefinitions.append(def)
					}
				}
			}
		}

		if let logoTemplate = logoTemplate, let logo = logoTemplate.image,
			let pngData = logo.pngRepresentation()
		{
			// Store the image in the SVG as a base64 string

			let abspath = logoTemplate.absolutePathForMaskPath(dimension: CGFloat(dimension))
			let bounds = abspath.boundingBoxOfPath.insetBy(dx: logoTemplate.inset, dy: logoTemplate.inset)

			let imageb64d = pngData.base64EncodedData(options: [.lineLength64Characters, .endLineWithLineFeed])
			let strImage = String(data: imageb64d, encoding: .ascii)!

			let dp = abspath.svgDataPath()
			var clipPath = "   <clipPath id=\"logo-mask\">\n"
			clipPath += "      <path d=\"\(dp)\" />\n"
			clipPath += "   </clipPath>\n"
			pathDefinitions.append(clipPath)

			svg += " <image clip-path=\"url(#logo-mask)\" x=\"\(bounds.origin.x)\" y=\"\(bounds.origin.y)\" width=\"\(bounds.size.width)\" height=\"\(bounds.size.height)\" "

			svg += "xlink:href=\"data:image/png;base64,"
			svg += strImage
			svg += "\" />"
		}

		if pathDefinitions.count > 0 {
			svg += "<defs>\n"
			for def in pathDefinitions {
				svg.append(def)
			}
			svg += "</defs>\n"
		}

		svg += "</svg>\n"

		return svg
	}

	/// Returns utf8-encoded SVG data for this qr code
	/// - Parameters:
	///   - dimension: The dimension of the output svg
	///   - design: The design for the QR Code
	///   - logoTemplate: The logo template to use when generating the svg data
	/// - Returns: An SVG representation of the QR code
	///
	/// The string always uses Unix newlines (\n), regardless of the platform.
	@objc func svgData(
		dimension: Int,
		design: QRCode.Design,
		logoTemplate: QRCode.LogoTemplate? = nil
	) -> Data? {
		let str = self.svg(dimension: dimension, design: design, logoTemplate: logoTemplate)
		return str.data(using: .utf8, allowLossyConversion: false)
	}
}
