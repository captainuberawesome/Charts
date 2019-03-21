//
//  Int+ShortText.swift
//  Charts
//
//  Created by iOS Developer on 21/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

extension Int {
  var shortText: String {
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 1
    numberFormatter.decimalSeparator = "."
    if self < 1000 {
      return "\(self)"
    } else if self < 1000000 {
      let thousands = NSNumber(value: Double(self) / 1000.0)
      return "\(numberFormatter.string(from: thousands) ?? String(describing: self)) K"
    } else {
      let million = NSNumber(value: Double(self) / 1000000.0)
      return "\(numberFormatter.string(from: million) ?? String(describing: self)) M"
    }
  }
}
