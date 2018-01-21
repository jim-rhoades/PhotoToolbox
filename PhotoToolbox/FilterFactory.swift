//
//  FilterFactory.swift
//  PhotoToolbox
//
//  Created by Jim Rhoades on 1/21/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

enum FilterType {
	case none
	case sepia
	
	static let allValues: [FilterType] = [.none, .sepia]
}

struct FilterFactory {
	
	static func processImage(_ inputImage: UIImage, usingFilter filterType: FilterType) -> UIImage? {
		
		// if filterType was specified as .none, just return the inputImage
		if filterType == .none {
			return inputImage
		}
		
		guard let ciImage = CIImage(image: inputImage) else {
			return nil
		}
		
		
		// TODO: separate this out into different functions for each filter type
		guard let filter = CIFilter(name: "CISepiaTone") else {
			return nil
		}
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(0.5, forKey: kCIInputIntensityKey)
		
		
		
		guard let outputImage = filter.outputImage else {
			return nil
		}
		
		// convert the output image to a CGImage
		// (because UIImages created using CIImages may not be displayed in a UIImageView properly,
		//   since they don't support contentMode)
		let ciContext = CIContext(options: nil)
		guard let cgImage = ciContext.createCGImage(outputImage, from: ciImage.extent) else {
			return nil
		}
		
		// could be improved using OpenGL?
		// see: https://www.objc.io/issues/21-camera-and-photos/core-image-intro/
		
		// create the final UIImage in a way that keeps the inputImage's orientation
		return UIImage(cgImage: cgImage, scale: 1.0, orientation: inputImage.imageOrientation)
	}
}
