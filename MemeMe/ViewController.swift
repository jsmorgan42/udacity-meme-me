//
//  ViewController.swift
//  MemeMe
//
//  Created by Jesse Morgan on 11/25/19.
//  Copyright © 2019 Jesse Morgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBOutlet var topText: UITextField!
    @IBOutlet var bottomText: UITextField!
    
    let imageCameraPicker = UIImagePickerController()
    let imageAlbumPicker = UIImagePickerController()
    
    var memedImage: UIImage!
    
    var cameraBarButton: UIBarButtonItem!
    var albumBarButton: UIBarButtonItem!
    
    struct Meme {
        var topText: String
        var bottomText: String
        
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareMeme))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelMeme))
        
        // Show navigation controller’s built-in toolbar
        navigationController?.setToolbarHidden(false, animated: false)

        // Set the view controller toolbar items
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.cameraBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(pickImageFromCamera))
        self.albumBarButton = UIBarButtonItem(title: "Album", style: .plain, target: self, action: #selector(pickImageFromAlbum))
        let flexibleSpace2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let items = [flexibleSpace1, cameraBarButton, albumBarButton, flexibleSpace2]
        setToolbarItems(items as? [UIBarButtonItem], animated: false)
        
        topText.delegate = self
        bottomText.delegate = self
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -2
        ]

        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        
    }
    
    @objc func shareMeme() {
        let memedImage = generateMemedImage()
//        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: memedImage)
        let activityItem: [AnyObject] = [memedImage as AnyObject]
        let controller = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func cancelMeme() {
        
    }

    @objc func pickImageFromAlbum() {
        imageCameraPicker.delegate = self
        imageCameraPicker.sourceType = .photoLibrary
        present(imageCameraPicker, animated: true, completion: nil)
    }
    
    @objc func pickImageFromCamera() {
        imageAlbumPicker.delegate = self
        imageAlbumPicker.sourceType = .camera
        present(imageAlbumPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if image.size.width > image.size.height {
                imageView.contentMode = .scaleAspectFit
            } else {
                imageView.contentMode = .scaleAspectFill
            }
            imageView.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y -= getKeyboardHeight(sender)
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = (userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        return keyboardSize?.height ?? 0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.isNavigationBarHidden = true
        navigationController?.setToolbarHidden(true, animated: false)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.setToolbarHidden(false, animated: false)

        return memedImage
    }
    
}

