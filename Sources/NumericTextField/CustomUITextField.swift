//
//  CustomUITextField.swift
//  iosApp
//
//  Created by Alama on 3/20/21.
//  Copyright © 2021 orgName. All rights reserved.
//

import Foundation


import UIKit


class CustomUITextField: UITextField {
    var delagate: ((UITextField)->Void)?
    
    
    override func deleteBackward(){
        super.deleteBackward()
        
        delagate?(self)
    }
}
