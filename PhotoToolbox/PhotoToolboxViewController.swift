//
//  PhotoToolboxViewController.swift
//  PhotoToolbox
//
//  Created by Jim Rhoades on 1/20/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import UIKit

public protocol PhotoToolboxDelegate: class {
	func finishedEditing(filteredPhoto: UIImage)
	func canceledEditing()
}

class PhotoToolboxViewController: UIViewController {
	
	@IBOutlet weak var photoView: UIImageView!
	var photo: UIImage!
	weak var delegate: PhotoToolboxDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// note that the 'photo' var is set when calling the 'editPhoto'
		// class method of PhotoToolbox
		photoView.image = photo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	@IBAction func applyFilter(_ sender: Any) {
		
		// TODO: add a way to specify different filters (picker controller?)
		guard let filteredImage = FilterFactory.processImage(photo, usingFilter: .sepia) else {
			return
		}
		
		photo = filteredImage
		photoView.image = filteredImage
		
		// filter has been applied, enable the Save button
		navigationItem.rightBarButtonItem?.isEnabled = true
	}
	
	@IBAction func saveButtonPressed(_ sender: Any) {
		delegate?.finishedEditing(filteredPhoto: photo)
	}
	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		delegate?.canceledEditing()
	}
}
