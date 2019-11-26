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
    
    var memedImage: UIImage!
    
    @IBOutlet var toolBar: UIToolbar!
    
    struct Meme {
        var topText: String
        var bottomText: String
        
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
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
        let image = generateMemedImage()
        let activityItem: [AnyObject] = [image as AnyObject]
        let controller = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func cancelMeme() {
        
    }

    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
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
    
    func save() {
            // Create the meme
            let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.isNavigationBarHidden = true
        self.toolBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.navigationController?.isNavigationBarHidden = false
        self.toolBar.isHidden = false

        return memedImage
    }
    
}

