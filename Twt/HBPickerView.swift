//
//  HBPickerView.swift
//  CustomPicker
//
//  Created by Tedmob IMac on 8/4/16.
//  Copyright © 2016 iOS Team. All rights reserved.
//

import UIKit

class HBPickerView: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var parent: UIViewController?
    
    var pickerView: UIView?
    
    var picker: UIPickerView?
    
    var toolbar: UIToolbar?
    
    var datasource: [AnyObject]?
    
    var pickerNumberOfRows: ((component: Int)->Int)?
    
    var pickerNumberOfComponents: (()->Int)?
    
    var pickerRowTitle: ((forRow: Int, inComponent: Int)->String)?
    
    var pickerDidSelect: ((row: Int, component:Int)->Void)?
    
    var hasToolbar: Bool = false
    
    var pickerViewHeight: CGFloat = 216.0
    
    var pickerBackgroundColor: UIColor?
    
    var hasBackgroundBlur: Bool = false
    
    var didDismiss: ((flag: Bool)->Void)?
    
    init(parent: UIViewController) {
        self.parent = parent
        super.init()
    }
    
    func setupPicker(){
        pickerView = UIView(frame: CGRectMake(0,   parent!.view.frame.size.height+44, parent!.view.frame.size.width, pickerViewHeight))
        
        picker = UIPickerView(frame: CGRectMake(0, 0, parent!.view.frame.size.width, pickerViewHeight))
        picker?.delegate = self
        picker?.dataSource = self
        
        if let backgorundColor = pickerBackgroundColor{
            picker?.backgroundColor = backgorundColor
        }
        
        if hasBackgroundBlur{
            picker?.backgroundColor = UIColor(white: 1, alpha: 0.5)
            
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = pickerView!.bounds
            
            pickerView?.addSubview(blurView)
        }
        
        if hasToolbar{
            toolbar = UIToolbar(frame: CGRectMake(0, parent!.view.frame.size.height, pickerView!.frame.size.width, 44))
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneButtonTapped))
            let flexible = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            toolbar?.items = [flexible, doneButton]
        }
        
        pickerView?.addSubview(picker!)
        
        parent?.view.addSubview(toolbar!)
        parent?.view.addSubview(pickerView!)
    }
    
    func selectedPicker(index: Int){
        picker?.selectRow(index, inComponent: 0, animated: true)
    }
    
    func doneButtonTapped(){
        dismissPicker()
    }
    
    func presentPicker(){
        if picker == nil{
            setupPicker()
        }
        
        UIView.animateWithDuration(0.3, animations: {
            self.pickerView?.transform = CGAffineTransformMakeTranslation(0, -(self.pickerViewHeight+44))
            self.toolbar?.transform = CGAffineTransformMakeTranslation(0, -(self.pickerViewHeight+44))
        }) { (finished) in
            
        }
    }
    
    func dismissPicker(){
        UIView.animateWithDuration(0.3, animations: {
            self.pickerView?.transform = CGAffineTransformIdentity
            self.toolbar?.transform = CGAffineTransformIdentity
        }) { (finished) in
            self.didDismiss!(flag: true)
        }
    }
    
    //MARK: UIPickerViewDatasource Methods
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerNumberOfRows!(component: component)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerNumberOfComponents!()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerRowTitle!(forRow: row, inComponent: component)
    }
    
    //MARK: UIPickerViewDelegate Methods
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerDidSelect!(row: row, component: component)
    }
}
