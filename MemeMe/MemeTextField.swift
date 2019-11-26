//
//  MemeText.swift
//  MemeMe
//
//  Created by Jesse Morgan on 11/25/19.
//  Copyright © 2019 Jesse Morgan. All rights reserved.
//

import UIKit


class MemeTextField : UITextField, UITextFieldDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
