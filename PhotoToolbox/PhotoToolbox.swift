//
//  PhotoToolbox.swift
//  PhotoToolbox
//
//  Created by Jim Rhoades on 1/20/18.
//  Copyright © 2018 Crush Apps. All rights reserved.
//

import Foundation

public protocol PhotoToolboxDelegate: class {
	func finishedEditing(filteredPhoto: UIImage)
	func canceledEditing()
}

public class PhotoToolbox {
	
	/**
		Presents the UI for editing a photo.
	
		- Parameter photo: 							The UIImage to be edited.
		- Parameter presentingViewController:		The UIViewController calling this method. Note that the presentingViewController MUST conform to the PhotoToolboxDelegate protocol.
	*/
	static public func editPhoto(_ photo: UIImage, presentingViewController: UIViewController) {
		
		// load and configure the PhotoToolboxViewController
		let bundle = Bundle(identifier: "com.crushapps.PhotoToolbox")
		let storyboard = UIStoryboard(name: "Main", bundle: bundle)
		guard let navController = storyboard.instantiateInitialViewController() as? UINavigationController else {
			print("failed to load UINavigationController")
			return
		}
		guard let photoToolboxViewController = navController.topViewController as? PhotoToolboxViewController else {
			print("failed to load PhotoToolboxViewController")
			return
		}
		photoToolboxViewController.originalPhoto = photo
		photoToolboxViewController.delegate = presentingViewController as? PhotoToolboxDelegate
		presentingViewController.present(navController, animated: true, completion: nil)
	}
}
