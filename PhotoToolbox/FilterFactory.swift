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
	case bloom = "Cross process + bloom"
	case kaleidoscope = "Kaleidoscope"
	
	static let allValues: [FilterType] = [.none,
										  .colorMatrix,
										  .noir,
										  .sepia,
										  .bloom,
										  .kaleidoscope]
}

class FilterFactory {
	
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
		case .bloom:
			outputImage = bloomImageFor(ciImage)
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
			 "inputRVector": CIVector(x: 0.9, y: 0, z: 0, w: 0),
			 "inputGVector": CIVector(x: 0.1, y: 1, z: 0.2, w: 0),
			 "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
			 "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)])
		
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
	
	private static func bloomImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CIPhotoEffectProcess", withInputParameters:
			[kCIInputImageKey: inputImage])
		
		// pass the output of the CIPhotoEffectProcess filter into the CIBloom filter
		let bloomImage = filter?.outputImage?.applyingFilter("CIBloom",
															parameters: [
																kCIInputRadiusKey: 10.0,
																kCIInputIntensityKey: 1.0
			])
		return bloomImage
	}
	
	private static func kaleidoscopeImageFor(_ inputImage: CIImage) -> CIImage? {
		let filter = CIFilter(name: "CIKaleidoscope", withInputParameters:
			[kCIInputImageKey: inputImage])
		
		// place the center point of the effect at the center point of the image
		let size = inputImage.extent.size
		let center = CGPoint(x: size.width / 2, y: size.height / 2)
		let vector = CIVector(cgPoint: center)
		filter?.setValue(vector, forKey: kCIInputCenterKey)
		
		// set it to have 12 nodes
		filter?.setValue(12, forKey: "inputCount") // there is no kCIInputCountKey?
		
		// set the angle
		// filter?.setValue(45, forKey: kCIInputAngleKey)
		
		return filter?.outputImage
	}
	
	
	// MARK: - Utility
	static func builtInFilterNames() -> [String] {
		return CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
	}
}
