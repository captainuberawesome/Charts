//
//  DayNightModeToggler.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

enum DisplayColorMode {
  case night, day
}

class DayNightModeToggler {
  var currentMode: DisplayColorMode = .day
  
  func toggle() {
    switch currentMode {
    case .day:
      currentMode = .night
    case .night:
      currentMode = .day
    }
  }
  
  var darkBackgroundColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.darkBackgroundColor
    case .night:
      return UIColor.DarkThemeColors.darkBackgroundColor
    }
  }
  
  var lightBackgroundColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.lightBackgroundColor
    case .night:
      return UIColor.DarkThemeColors.lightBackgroundColor
    }
  }
  
  var separatorColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.separatorColor
    case .night:
      return UIColor.DarkThemeColors.separatorColor
    }
  }
  
  var brightTextColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.brightTextColor
    case .night:
      return UIColor.DarkThemeColors.brightTextColor
    }
  }
  
  var dullerTextColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.dullerTextColor
    case .night:
      return UIColor.DarkThemeColors.dullerTextColor
    }
  }
  
  var dullestTextColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.dullestTextColor
    case .night:
      return UIColor.DarkThemeColors.dullestTextColor
    }
  }
  
  var chartBackgroundLinesColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.chartBackgroundLinesColor
    case .night:
      return UIColor.DarkThemeColors.chartBackgroundLinesColor
    }
  }
  
  var bubbleBackgroundColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.bubbleBackgroundColor
    case .night:
      return UIColor.DarkThemeColors.bubbleBackgroundColor
    }
  }
  
  var draggableViewHandleColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.draggableViewHandleColor
    case .night:
      return UIColor.DarkThemeColors.draggableViewHandleColor
    }
  }
  
  var draggableViewOverlayColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.draggableViewOverlayColor
    case .night:
      return UIColor.DarkThemeColors.draggableViewOverlayColor
    }
  }
  
  var navbarBackgroundColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.navbarBackgroundColor
    case .night:
      return UIColor.DarkThemeColors.navbarBackgroundColor
    }
  }
  
  var miniatureChartBackgroundColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.miniatureChartBackgroundColor
    case .night:
      return UIColor.DarkThemeColors.miniatureChartBackgroundColor
    }
  }
  
  var selectionBubbleVerticalLineColor: UIColor {
    switch currentMode {
    case .day:
      return UIColor.LightThemeColors.bubbleVerticalLineBackgroundColor
    case .night:
      return UIColor.DarkThemeColors.bubbleBackgroundColor
    }
  }
}
