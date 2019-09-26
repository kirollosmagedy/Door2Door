//
//  UIButton+Extension.swift
//  door2doorDemo
//
//  Created by Kiro on 9/26/19.
//  Copyright © 2019 Kiro. All rights reserved.
//

import UIKit


extension UIButton {
    func disableButton() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.gray
    }
    
    func enableButton() {
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.black
    }
}
