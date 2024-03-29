//
//  UIColor+Hex.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(hexString: String) {
    guard !hexString.isEmpty else {
      self.init(white: 0, alpha: 1)
      return
    }
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt32 = 0
    Scanner(string: hex).scanHexInt32(&int)
    
    let alpha: UInt32
    let red: UInt32
    let green: UInt32
    let blue: UInt32
    
    switch hex.count {
    case 3:
      (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:
      (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
      (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (alpha, red, green, blue) = (255, 0, 0, 0)
    }
    
    self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
  }
}
