//
//  UIColor+AppColors.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

extension UIColor {
  // MARK: - Common
  
  class func color(fromRed red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
    return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
  }
  
  // MARK: - Colors
  
  struct LightThemeColors {
    static let darkBackgroundColor = UIColor.color(fromRed: 239, green: 239, blue: 244)
    static let lightBackgroundColor = UIColor.white
    static let separatorColor = UIColor.lightGray.withAlphaComponent(0.3)
    static let brightTextColor = UIColor.black
    static let dullerTextColor = UIColor.darkGray
    static let dullestTextColor = UIColor.gray
    static let chartBackgroundLinesColor = UIColor.lightGray.withAlphaComponent(0.5)
    static let bubbleBackgroundColor =  UIColor.color(fromRed: 240, green: 240, blue: 245)
    static let draggableViewHandleColor = UIColor.color(fromRed: 202, green: 212, blue: 222, alpha: 0.9)
    static let draggableViewOverlayColor = UIColor.color(fromRed: 239, green: 239, blue: 244, alpha: 0.6)
    static let navbarBackgroundColor = UIColor.color(fromRed: 247, green: 247, blue: 247)
    static let miniatureChartBackgroundColor = UIColor.white
  }
  
  struct DarkThemeColors {
    static let darkBackgroundColor = UIColor.color(fromRed: 24, green: 34, blue: 45)
    static let lightBackgroundColor = UIColor.color(fromRed: 33, green: 47, blue: 63)
    static let separatorColor = UIColor.color(fromRed: 18, green: 26, blue: 35)
    static let brightTextColor = UIColor.white
    static let dullerTextColor = UIColor.white
    static let dullestTextColor = UIColor.color(fromRed: 91, green: 107, blue: 127)
    static let chartBackgroundLinesColor = UIColor.color(fromRed: 27, green: 39, blue: 52)
    static let bubbleBackgroundColor = UIColor.color(fromRed: 26, green: 40, blue: 55)
    static let draggableViewHandleColor = UIColor.color(fromRed: 91, green: 110, blue: 131, alpha: 0.9)
    static let draggableViewOverlayColor = UIColor.color(fromRed: 24, green: 34, blue: 45, alpha: 0.6)
    static let navbarBackgroundColor = UIColor.color(fromRed: 33, green: 48, blue: 64)
    static let miniatureChartBackgroundColor = UIColor.color(fromRed: 33, green: 47, blue: 63)
  }
}
