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
  private var onDayNightModeToggled: (() -> Void)?
  
  init(window: UIWindow) {
    self.window = window
    window.rootViewController = navigationController
    navigationController.configureNavigationBarAppearance(dayNightModeToggler: dayNightModeToggler)
    charts = DataImporter.importData(jsonFileName: "chart_data")
  }
  
  func start() {
    window.makeKeyAndVisible()
    showChartListScreen()
  }
  
  func showChartListScreen() {
    let viewController = ChartListViewController(charts: charts, dayNightModeToggler: dayNightModeToggler)
    viewController.delegate = self
    viewController.title = "Chart List"
    onDayNightModeToggled = { [weak viewController, unowned dayNightModeToggler] in
      viewController?.configure(dayNightModeToggler: dayNightModeToggler)
    }
    navigationController.pushViewController(viewController, animated: false)
  }
  
  func showChartScreen(for chart: Chart, title: String) {
    guard !(navigationController.topViewController is ChartViewController) else { return }
    let viewController = ChartViewController(chart: Chart(chart: chart), chartName: title,
                                             dayNightModeToggler: dayNightModeToggler)
    viewController.delegate = self
    viewController.title = "Statistics"
    navigationController.pushViewController(viewController, animated: true)
  }
}

// MARK: - ChartListViewControllerDelegate

extension ChartsCoordinator: ChartListViewControllerDelegate {
  func chartListViewController(_ viewController: ChartListViewController, didSelectChart chart: Chart, title: String) {
    showChartScreen(for: chart, title: title)
  }
}

// MARK: - ChartViewControllerDelegate

extension ChartsCoordinator: ChartViewControllerDelegate {
  func chartViewControllerDidToggleDayNightMode(_ viewController: ChartViewController) {
    navigationController.configureNavigationBarAppearance(dayNightModeToggler: dayNightModeToggler)
    onDayNightModeToggled?()
  }
}
