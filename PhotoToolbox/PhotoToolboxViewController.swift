//
//  PhotoToolboxViewController.swift
//  PhotoToolbox
//
//  Created by Jim Rhoades on 1/20/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

class PhotoToolboxViewController: UIViewController {
	
	@IBOutlet weak var filterPicker: UIPickerView!
	@IBOutlet weak var photoView: UIImageView!
	var originalPhoto: UIImage!
	var filteredPhoto: UIImage?
	weak var delegate: PhotoToolboxDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// note that the 'originalPhoto' var is set when calling the 'editPhoto'
		// class method of PhotoToolbox
		photoView.image = originalPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func saveButtonPressed(_ sender: Any) {
		
		// if the photo wasn't filtered, just cancel / dismiss
		guard let filteredPhoto = filteredPhoto else {
			delegate?.canceledEditing()
			return
		}
		
		delegate?.finishedEditing(filteredPhoto: filteredPhoto)
	}
	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		delegate?.canceledEditing()
	}
}

extension PhotoToolboxViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return FilterType.allValues.count
	}
}

extension PhotoToolboxViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return FilterType.allValues[row].rawValue
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		let filterType = FilterType.allValues[row]
		
		if filterType == .none {
			filteredPhoto = nil
			photoView.image = originalPhoto
			navigationItem.rightBarButtonItem?.isEnabled = false // disable save button
		} else {
			// apply a filter to the original photo
			guard let filteredImage = FilterFactory.processImage(originalPhoto, usingFilter: filterType) else {
				return
			}
			filteredPhoto = filteredImage
			photoView.image = filteredImage
			navigationItem.rightBarButtonItem?.isEnabled = true // enable save button
		}
	}
}
