//
//  ViewController.swift
//  Photo Editor
//
//  Created by Jim Rhoades on 1/20/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit
import PhotoToolbox

class ViewController: UIViewController, UINavigationControllerDelegate {
	
	@IBOutlet weak var editPhotoButton: UIButton!
	@IBOutlet weak var photoView: UIImageView!
	var photo: UIImage?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction func choosePhoto(_ sender: Any) {
		guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
			print("photo library is not available")
			return
		}
		
		let picker = UIImagePickerController()
		picker.delegate = self
		present(picker, animated: true, completion: nil)
	}
	
	@IBAction func editPhoto(_ sender: Any) {
		guard let photo = photo else {
			print("there is no photo to edit")
			return
		}
		
		// edit the photo using the PhotoToolbox framework
		PhotoToolbox.editPhoto(photo, presentingViewController: self)
	}
	
	func resetInterface() {
		photo = nil
		photoView.image = UIImage(named: "image_placeholder")
		editPhotoButton.isEnabled = false
	}
}

extension ViewController: UIImagePickerControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			print("failed to get image")
			resetInterface()
			dismiss(animated: true, completion: nil)
			return
		}
		
		photo = pickedImage
		photoView.image = photo
		editPhotoButton.isEnabled = true
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
}

extension ViewController: PhotoToolboxDelegate {
	func finishedEditing(filteredPhoto: UIImage) {
		photo = filteredPhoto
		photoView.image = filteredPhoto
		dismiss(animated: true, completion: nil)
	}
	
	func canceledEditing() {
		dismiss(animated: true, completion: nil)
	}
}
