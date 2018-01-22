# PhotoToolbox

A weekend hack put together to familiarize myself with building a framework and to refresh my memory with Core Image.

The "PhotoToolbox" framework presents a view controller that allows you to apply various filters to a photo.

**An example app named "Photo Editor" is included to show how it works.**

## Usage

Call PhotoToolbox's `editPhoto` method from the view controller that you wish to present it from, along with the UIImage that you want to edit:

`PhotoToolbox.editPhoto(photo, presentingViewController: self)`

Note that the presenting view controller needs to conform to the PhotoToolboxDelegate protocol, so that it can do something with the filtered photo:

```
extension ViewController: PhotoToolboxDelegate {
	func finishedEditing(filteredPhoto: UIImage) {
		photo = filteredPhoto
		photoView.image = filteredPhoto
    
		// TODO: save the filtered photo to the camera roll if desired
    
		dismiss(animated: true, completion: nil)
	}
	
	func canceledEditing() {
		dismiss(animated: true, completion: nil)
	}
}
```





