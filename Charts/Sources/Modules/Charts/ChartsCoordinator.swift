//
//  ChartsCoordinator.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartsCoordinator {
  private let dayNightModeToggler = DayNightModeToggler()
  private let window: UIWindow
  private let navigationController = NavigationController()
  private let charts: [Chart]
  
  init(window: UIWindow) {
    self.window = window
    window.rootViewController = navigationController
    window.tintColor = UIColor.tintColor
    navigationController.configureNavigationBarAppearance(dayNightModeToggler: dayNightModeToggler)
    charts = DataImporter.importData(jsonFileName: "chart_data")
  }
  
  func start() {
    window.makeKeyAndVisible()
    showChartScreen(charts: charts)
  }
  
  func showChartScreen(charts: [Chart]) {
    let viewController = ChartViewController(charts: charts, dayNightModeToggler: dayNightModeToggler)
    viewController.delegate = self
    viewController.title = "Statistics"
    navigationController.pushViewController(viewController, animated: true)
  }
}

// MARK: - ChartViewControllerDelegate

extension ChartsCoordinator: ChartViewControllerDelegate {
  func chartViewControllerDidToggleDayNightMode(_ viewController: ChartViewController) {
    navigationController.configureNavigationBarAppearance(dayNightModeToggler: dayNightModeToggler)
  }
}
