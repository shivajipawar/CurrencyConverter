//
//  ExtensionString.swift
//  CurrencyConverter
//
//  Created by Shivaji N Pawar on 3/21/18.
//  Copyright © 2018 rohit karyappa. All rights reserved.
//

import Foundation

extension String {
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        if formatter.number(from: self) != nil {
            let split = self.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.characters.count <= maxDecimalPlaces
        }
        return false
    }
}
