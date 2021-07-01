//
//  File.swift
//  
//
//  Created by Alama on 4/24/21.
//

import Foundation


/*
 This regex matches any int(i.e: 123) or decimal digit(123.456).
 
 Explnation:
 '^' = Assert position at start of a string/line.
 '[\d]' = matches a single character(in this case a single digit) in the list.
 '+' = quantifier, matches 1 or more character. I.e: '[\d]+' matches 1 or more digit.
 '\.' = matches dot '.'. Need to escape the dot
 '?' = matches 0 or 1 character. I.e:  '\.?' matches 0 or 1 dot '.'
 '([\d]+)' = '()' means group.'([\d])' means any single digit. '([\d]+)' means 1 or more digit.
 '([\d]+)?' = means 0 or more digit
 '$' = Assert position at the end of a string. Meaning if string has a whitespac(tab, line break, etc..), all those will be ignore(not a match), in case somone goes again an enter space or tab etc../
 
 i.e:
 value = "123" ---> match. Decimal point is optional. See '\.?'
 value = "123." ---> match. Decimal point is optional 0 or 1. See '\.?'
 value = "123.4" ---> match
 value = "123.456" ---> match
 value = "123 " ---> NO match, String ends with whitespace. See '$'
 value = "123.34 " ---> NO match, String ends with whitespace. See '$'
 value = "a123.34 " ---> NO match, String start with 'a'. We want string to start with digit. See '^[\d]'
 value = "123.34aa " ---> NO match, String end with 'a'. We want string to end with digit. See '([\\d]+)?$'
 value = "" ---> NO match. Empty string
 */
let DECIMAL_NYMBER_REGGEX_PATTERN = "^[\\d]+\\.?([\\d]+)?$" //we need to escape any backslash
/* Same as 'DECIMAL_NYMBER_REGGEX_PATTERN' but also matcher number with grouping. i.e: 1,000.12 or 12,345.44 or 1,000,000.0*/

let DECIMAL_NYMBER_GROUPING_REGGEX_PATTERN = "^([\\d]+([\\,]?[\\d]+)*)+\\.?([\\d]+)?" //we need to escape any backslash

/* Same as 'DECIMAL_NYMBER_REGGEX_PATTERN' but only matches whole number(decimal number is not allowed) */
let WHOLE_NYMBER_REGGEX_PATTERN = "^[\\d]+$" //we need to escape any backslash
/* Same as 'WHOLE_NYMBER_REGGEX_PATTERN' but also matches whole number(decimal number is not allowed) with grouping. i.e: 1,000 or 12,345 or 1,000,000*/
let WHOLE_NYMBER_GROUPING_REGGEX_PATTERN = "^([\\d]+\\,?([\\d]+)?)+$" //we need to escape any backslash

func isThisAValidDecimalNumber(_ value: String) -> Bool {
    return value.match(DECIMAL_NYMBER_REGGEX_PATTERN)
}

func isThisAValidDecimalNumberWithGrouping(_ value: String) -> Bool {
    return value.match(DECIMAL_NYMBER_GROUPING_REGGEX_PATTERN)
}

func isThisAValidWholeNumber(_ value: String) -> Bool {
    return value.match(WHOLE_NYMBER_REGGEX_PATTERN)
}

func isThisAValidWholeNumberWithGrouping(_ value: String) -> Bool {
    return value.match(WHOLE_NYMBER_GROUPING_REGGEX_PATTERN)
}


private extension String{
    func match(_ regex: String) -> Bool {
        guard let matchedRange = self.range(of: regex, options: String.CompareOptions.regularExpression) else {
            return false
        }
 
        let matchedPartition = String(self[matchedRange])
        
        return matchedPartition.caseInsensitiveCompare(self) == .orderedSame
    }
}
