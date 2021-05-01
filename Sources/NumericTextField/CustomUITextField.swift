//
//  CustomUITextField.swift
//  iosApp
//
//  Created by Alama on 3/20/21.
//  Copyright © 2021 orgName. All rights reserved.
//

import Foundation


import UIKit


public class CustomUITextField: UITextField {
    public var delagate: ((UITextField)->Void)?
    
    
    public override func deleteBackward(){
        super.deleteBackward()
        
        delagate?(self)
    }
}
