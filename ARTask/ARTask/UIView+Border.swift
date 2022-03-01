//
//  UIView+Border.swift
//  Park4You
//
//  Created by SixLogics on 10/04/2018.
//  Copyright © 2018 SixLogics. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
   
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = 0.4
            layer.shadowRadius = newValue
        }
    }
    
    class func containsEmptyFieldsInView(_ mainView: UIView) -> Bool {
        if let textField = mainView as? UITextField {
            if textField.text!.isEmpty {
                return true
            }
        }
        else if let textView = mainView as? UITextView {
            if textView.text!.isEmpty {
                return true
            }
        }
        else if mainView.subviews.count > 0 {
            for view: UIView in mainView.subviews{
                if UIView.containsEmptyFieldsInView(view){
                    return true
                }
            }
        }
        return false
    }
    
//    static var activityIndicator: UIActivityIndicatorView {
//        let indictaor = UIActivityIndicatorView(style: .gray)
//        indictaor.startAnimating()
//        indictaor.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44)
//        return indictaor
//    }
    
    func asImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
        
        //        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        //        return renderer.image { rendererContext in
        //            layer.render(in: rendererContext.cgContext)
        //        }
    }
}


