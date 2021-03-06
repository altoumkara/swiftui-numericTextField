//
//  NumericTextField.swift
//  iosApp
//
//  Created by Alama on 3/26/21.
//  Copyright © 2021 orgName. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit

public struct NumericTextField: UIViewRepresentable{
    private let maxValueDelegate : ((Bool)-> Bool)?
    
    private var maxAllowedNumber: NSDecimalNumber? = nil

    public enum NumberType: Int {
        case whole, decimal, decimalWtihGrouping, wholeWtihGrouping
        
        func isDecimal() -> Bool {
            return self == .decimalWtihGrouping || self == .decimal
        }
    }
        
    private var placeholder: String
    
    @Binding var number: String
    
    ///This can be something like the dollar sign '$'
    private var leadingAddition: String = "" //'Character' not possibe to create empty char in swift 4+
    
    ///This can be something like the percentage sign '%' or other thing like per word such as '/Year' or '/Month'
    private var trailingAddition: String = ""
    
    private var numberType: NumberType
        
    private var currencyFormatter: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        // formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 20
        
        return formatter
    }
    
    private var numberProxy: Binding<String>{
        Binding<String>(
            get: {
                log("\(Self.Type.self):::  NumericTextField: BEFORE get:::: number: \(number)  ::: Binding(....)")
                
                var currentTextFieldValue = number
                
                if !number.isEmpty{
                    currentTextFieldValue = formatNumber(number: number)
                }
                
                log("\(Self.Type.self):::  NumericTextField: AFTER get:::: number: \(number) ;;;; currentTextFieldValue: \(currentTextFieldValue)  ::: Binding(....)")
                
                return currentTextFieldValue
            },
            set: {
                let currentTextFieldValue = number
                
                ///getting rid of 'leadingAddition'
                var newValue = leadingAddition.isEmpty ? $0 : $0.replacingOccurrences(of: leadingAddition, with: "")
                ///getting rid of 'trailingAddition'
                newValue = trailingAddition.isEmpty ? newValue :newValue.replacingOccurrences(of: trailingAddition
                                                                                              , with: "")
                var isThisAValidANumber = true
                
                switch numberType{
                case .whole:  isThisAValidANumber = isThisAValidWholeNumber(newValue)
                case .decimal:  isThisAValidANumber = isThisAValidDecimalNumber(newValue)
                case .wholeWtihGrouping: isThisAValidANumber = isThisAValidWholeNumberWithGrouping(newValue)
                case .decimalWtihGrouping: isThisAValidANumber = isThisAValidDecimalNumberWithGrouping(newValue)
                }
                
                log("NumericTextField: set:::: isThisAValidANumber: \(isThisAValidANumber)  ;;;;  newValue: \(newValue) ;;;; $0: \($0)  ;;;; currentTextFieldValue: \(currentTextFieldValue)  ;;;; number: \(number) ;;;; currency: \(trailingAddition)  ::: Binding(....)")
                
                guard isThisAValidANumber else{
                    let _ = maxValueDelegate?(false)
                    
                    if newValue.isEmpty{
                        number = ""
                        
                        return
                    }
                    
                    log("number: \(number)  ;;; currentTextFieldValue: \(currentTextFieldValue)")
                    
                    number = currentTextFieldValue
                    
                    return
                }
                
                let newNumber = newValue.replacingOccurrences(of: ",", with: "")
                
                if maxAllowedNumber != nil && maxAllowedNumber!.decimalValue < NSDecimalNumber(string: newNumber ).decimalValue{
                    
                    if let delegate = maxValueDelegate, delegate(true){
                        number = currentTextFieldValue
                        
                        return
                    }
                }
                
                if number != newNumber{
                    let _ = maxValueDelegate?(false)
                    
                    number = newNumber
                    
                    log("newValue: \(newValue) ;;;  newNumber: \(newNumber)  ;;; number: \(number)  ;;;  if number != newValue{ ... }")
                }
            }
        )
    }
    
    public init(_ text: String,
         number numberBinding: Binding<String>,
         leadingAddition lAddition: String = "$",
         trailingAddition tAddition: String = "",
         numberType nType: NumberType = .wholeWtihGrouping,
         maxAllowedNumber maxNumber: NSDecimalNumber? = nil,
         maxValueDelegate delegate: ((Bool)-> Bool)? = nil) {

        
        placeholder = text
        
        //IMPORTANT: THIS IS HOW YOU INITIALIZE PROPERTIES ANNOTATED WITH @Binding AND @States.
        //  You need to use '_' prefxing the name of the property.
        //  See here for more info:
        //https://stackoverflow.com/questions/58758370/how-could-i-initialize-the-state-variable-in-the-init-function-in-swiftui
        _number = numberBinding
        
        leadingAddition = lAddition
        
        trailingAddition = tAddition

        numberType = nType
        
        maxAllowedNumber = maxNumber
        
        maxValueDelegate = delegate
        
        log("\(Self.Type.self):::  init(_ text .. ... ...)")
    }
  
    public func makeCoordinator() -> Coordinator {
        Coordinator(numericTextField: self)
    }

    public func makeUIView(context: Context) -> CustomUITextField{
        log("makeUIView(context: Context) CALLED-CALLED-CALLED-CALLED-CALLED-CALLED-CALLED")
        
        let textField = CustomUITextField()
                
        textField.delagate =  { (textField: UITextField)->Void in
            self.onPressed(textField)
        }
      
        textField.placeholder = NSLocalizedString(placeholder, comment: placeholder)
        
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textFieldDidChange(textField:)),
            for: .editingChanged
        )
        
        textField.text = numberProxy.wrappedValue
                
        ///make the soft-keyboard showing only numeric keys
        textField.keyboardType = numberType.isDecimal() ? .decimalPad : .numberPad
        
        return textField
    }
    
    public func updateUIView(_ uiView: CustomUITextField, context: Context){
        log("updateUIView(_ uiView: CustomUITextField, context: Context) CALLED-CALLED-CALLED-CALLED-CALLED-CALLED-CALLED")
        
        uiView.placeholder = NSLocalizedString(placeholder, comment: placeholder)
                
        uiView.text = numberProxy.wrappedValue
    }
    
    private func onPressed(_ textField: UITextField) {
        
        guard var textFieldValue = textField.text, !trailingAddition.isEmpty  else{
            
            return
        }
        
        ///getting rid of 'leadingAddition'
        textFieldValue = leadingAddition.isEmpty ? textFieldValue : textFieldValue.replacingOccurrences(of: addition(textFieldValue), with: "")
        ///getting rid of 'trailingAddition'
        textFieldValue = trailingAddition.isEmpty ? textFieldValue :textFieldValue.replacingOccurrences(of: addition(textFieldValue), with: "")
        
        log("BEFORE::: number: \(number)  ;;;textField.text: \(textField.text ?? "nil") ;;;;  textFieldValue: \(textFieldValue)  ;;;;onPressed()")
        
        ///getting rid of any  grouping
        let newNumber = textFieldValue.replacingOccurrences(of: ",", with: "").dropLast()
        
        number = String(newNumber)
        
        log("AFTER::: number: \(number)  ;;;textField.text: \(textField.text ?? "nil") ;;;;newNumber: \(newNumber) ;;;;  onPressed()")
    }
    
    private func formatNumber(number: String) -> String{
        var formattedNumber = ""

        let isNumberDecimal = numberType.isDecimal()
        
        if isNumberDecimal && number.last == "." {
            /// if User is trying to enter decimal number, we allow decimal point "."  to be entered,
            /// if you use 'currencyFormatter.string( from: NSDecimalNumber(string: number )  )!', the dot '.' will be removed each time you try to enter it. Hence,
            /// to avoid that, we need to split the whole number portion from the decimal point portion before formatting and only format the whole number portion.
            let numbs = number.split(separator: ".", maxSplits: 1)
        
            let wholeNumb = currencyFormatter.string( from: NSDecimalNumber( string: String(numbs[0]) ) )!
            
            formattedNumber = "\(wholeNumb)."
        }else if isNumberDecimal && number.contains(".") && number.last == "0" {
            /// If you are trying to enter '0' after a decimal point(basically, if the '0' is tha last value after a decimal point i.e: 1.0, 1.20, 4.990 etc..),
            /// using ': NSDecimalNumber(string: number ) '  or  'currencyFormatter.string( from: ..  )!' will remove the  last '0' that user entered  after a decimal point each time.
            /// Hence,  to avoid that, we need to split the whole number portion from the decimal point portion before formatting  and only format the whole number portion.
            let numbs = number.split(separator: ".", maxSplits: 1)
        
            let wholeNumb = currencyFormatter.string( from: NSDecimalNumber( string: String(numbs[0]) ) )!
            
            formattedNumber = "\(wholeNumb).\( String( numbs[1] ) )"
        }else{
           formattedNumber = currencyFormatter.string( from: NSDecimalNumber(string: number ) )!
        }
        
        return "\(leadingAddition)\(formattedNumber)\(trailingAddition)"
    }
    
    private func addition(_ value: String) -> String {
        //macth any non digit, non-grouping separator(',') and non-decimal point character ('.')
        let matchedCharacters = value.range(of: "[^\\d\\,\\.]+", options: String.CompareOptions.regularExpression)
        
        var subValue = ""
        if let matchedChar = matchedCharacters{
            //https://stackoverflow.com/questions/45562662/how-can-i-use-string-substring-in-swift-4-substringto-is-deprecated-pleas
            subValue = String(value[matchedChar]) //same as value.substring(with: matchedChar)
        }
        
        log("addition(..):::: matchedCharacters: \(String(describing: matchedCharacters)) ;;;;  subValue: \(subValue)")
        
        return subValue
    }
    
    public class Coordinator: NSObject, UITextFieldDelegate{
        let numericTextField: NumericTextField
        
        init(numericTextField: NumericTextField) {
            self.numericTextField = numericTextField
        }
        
        @objc func textFieldDidChange(textField: UITextField) {
            self.numericTextField.numberProxy.wrappedValue = textField.text ?? ""
        }
    }
    
    private func log(_ msg: String){
        //uncomment this line to print some debug logs
       /*debugPrint("Logger ===> \(msg)")*/
    }
}
