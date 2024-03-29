//
//  NavigationController.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .lightContent
  }
  
  override var prefersStatusBarHidden: Bool {
    return topViewController?.prefersStatusBarHidden ?? false
  }
  
  override var shouldAutorotate: Bool {
    return topViewController?.shouldAutorotate ?? true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController?.supportedInterfaceOrientations ?? .portrait
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return topViewController?.preferredStatusBarUpdateAnimation ?? .slide
  }
  
  // MARK: - Navigation Bar Appearance
  
  func configureNavigationBarAppearance(dayNightModeToggler: DayNightModeToggler) {
    navigationBar.isTranslucent = false
    let textColor: UIColor = dayNightModeToggler.brightTextColor
    let backgroundColor = dayNightModeToggler.navbarBackgroundColor
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.tintColor = textColor
    navigationBar.barTintColor = backgroundColor
    navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor,
                                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
  }
}
