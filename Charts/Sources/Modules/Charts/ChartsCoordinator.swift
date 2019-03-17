//
//  ChartsCoordinator.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartsCoordinator {
  private let window: UIWindow
  private let navigationController = NavigationController()
  
  init(window: UIWindow) {
    self.window = window
    window.rootViewController = navigationController
    navigationController.configureNavigationBarAppearance()
  }
  
  func start() {
    window.makeKeyAndVisible()
    let viewController = ChartViewController()
    viewController.title = "Statistics"
    navigationController.pushViewController(viewController, animated: false)
  }
}
