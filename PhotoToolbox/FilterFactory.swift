//
//  FilterFactory.swift
//  PhotoToolbox
//
//  Created by Jim Rhoades on 1/21/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

enum FilterType: String {
	case none = "No filter"
	case colorMatrix = "Color matrix"
	case noir = "Noir"
	case sepia = "Sepia (50% intensity)"
	case crossProcess = "Cross process + vignette"
	case kaleidoscope = "Kaleidoscope"
	
	static let allValues: [FilterType] = [.none,
										  .colorMatrix,
										  .noir,
										  .sepia,
										  .crossProcess,
										  .kaleidoscope]
}

class FilterFactory {
	
	/**
		Processes a UIImage using the specified filter
	
		- Parameter inputImage:		The UIImage to process.
		- Parameter filterType:		The filter to apply to the image.
	
		- Returns:	The filtered image as a UIImage.
	*/
	static func processImage(_ inputImage: UIImage, usingFilter filterType: FilterType) -> UIImage? {
		
		guard let ciImage = CIImage(image: inputImage) else {
			return nil
		}
		
		var outputImage: CIImage?
		switch filterType {
		case .none:
			return inputImage // just return the input image
		case .colorMatrix:
			outputImage = colorMatrixImageFor(ciImage)
		case .noir:
			outputImage = noirImageFor(ciImage)
		case .sepia:
			outputImage = sepiaImageFor(ciImage)
		case .crossProcess:
			outputImage = crossProcessImageFor(ciImage)
		case .kaleidoscope:
			outputImage = kaleidoscopeImageFor(ciImage)
		}
		
		guard let filteredImage = outputImage else {
			return nil
		}
		
		// convert the output image to a CGImage
		// (UIImages created using CIImages may not be displayed properly
		//   since they don't support UIImageView's contentMode)
		let ciContext = CIContext(options: nil)
		guard let cgImage = ciContext.createCGImage(filteredImage, from: ciImage.extent) else {
			return nil
		}
		
		// could be improved using OpenGL?
		// see: https://www.objc.io/issues/21-camera-and-photos/core-image-intro/
		
		// create the final UIImage in a way that keeps the inputImage's orientation
		return UIImage(cgImage: cgImage, scale: 1.0, orientation: inputImage.imageOrientation)
	}
	
	// MARK: - Filters
	
	private static func colorMatrixImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CIColorMatrix", withInputParameters:
			[kCIInputImageKey: inputImage,
			 "inputRVector": CIVector(x: 1.1, y: -0.1, z: -0.1, w: -0.1),
			 "inputGVector": CIVector(x: 0, y: 0.9, z: 0, w: 0),
			 "inputBVector": CIVector(x: 0, y: 0, z: 1.1, w: 0),
			 "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1.1)])
		
		return filter?.outputImage
	}
	
	private static func noirImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CIPhotoEffectNoir", withInputParameters:
			[kCIInputImageKey: inputImage])
		
		return filter?.outputImage
	}
	
	private static func sepiaImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CISepiaTone", withInputParameters:
			[kCIInputImageKey: inputImage,
			 kCIInputIntensityKey: 0.5])
		
		return filter?.outputImage
	}
	
	private static func crossProcessImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CIPhotoEffectProcess", withInputParameters:
			[kCIInputImageKey: inputImage])
		
		// pass the output of the CIPhotoEffectProcess filter into the CIVignette filter
		let vignetteImage = filter?.outputImage?.applyingFilter("CIVignette", parameters:
			[kCIInputRadiusKey: 1.5,
			 kCIInputIntensityKey: 1.0])
		
		return vignetteImage
	}
	
	private static func kaleidoscopeImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CIKaleidoscope", withInputParameters:
			[kCIInputImageKey: inputImage])
		
		// place the center point of the effect at the center point of the image
		let size = inputImage.extent.size
		let center = CGPoint(x: size.width / 2, y: size.height / 2)
		let vector = CIVector(cgPoint: center)
		filter?.setValue(vector, forKey: kCIInputCenterKey)
		
		// set the number of nodes
		filter?.setValue(4, forKey: "inputCount") // there is no kCIInputCountKey?
		
		// crop to the original size of the image
		let cropVector = CIVector(cgRect: inputImage.extent)
		let croppedImage = filter?.outputImage?.applyingFilter("CICrop",
															   parameters: ["inputRectangle" : cropVector])
		
		return croppedImage
	}
	
	
	// MARK: - Utility
	static func builtInFilterNames() -> [String] {
		return CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
	}
}
