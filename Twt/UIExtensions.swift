//
//  UIExtensions.swift
//  Venda
//
//  Created by Hussein Bawab on 6/8/16.
//  Copyright © 2016 Hussein Bawab. All rights reserved.
//

import UIKit

extension UIView{
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(CGColor: layer.borderColor!)
        }set {
            layer.borderColor = newValue?.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor?{
        get{
            return UIColor(CGColor: layer.shadowColor!)
        } set{
            layer.shadowColor = newValue?.CGColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize{
        get{
            return layer.shadowOffset
        } set{
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        get{
            return layer.shadowOpacity
        } set{
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        get{
            return layer.shadowRadius
        } set{
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var masksToBounds: Bool{
        get {
            return layer.masksToBounds
        } set{
            layer.masksToBounds = newValue
        }
    }
}

extension UITableView{
    @IBInspectable var rowHeightEstimate: CGFloat{
        get {
            return estimatedRowHeight
        } set{
            estimatedRowHeight = newValue
        }
    }
    
    @IBInspectable var automaticDimensionEnabled: Bool{
        get {
            return rowHeight == UITableViewAutomaticDimension ? true : false
        } set{
            rowHeight = UITableViewAutomaticDimension
        }
    }
}

extension UINavigationBar{
    @IBInspectable var hideShadow: Bool{
        get{
            if self.shadowImage == nil{
                return false
            } else{
                return true
            }
        } set{
            if newValue{
                self.setBackgroundImage(UIImage(), forBarMetrics: .Default)
                self.shadowImage = UIImage()
            } else{
                self.setBackgroundImage(nil, forBarMetrics: .Default)
                self.shadowImage = nil
            }
        }
    }
}
