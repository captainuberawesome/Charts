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
  private let charts: [Chart]
  
  init(window: UIWindow) {
    self.window = window
    window.rootViewController = navigationController
    navigationController.configureNavigationBarAppearance()
    charts = DataImporter.importData(jsonFileName: "chart_data")
  }
  
  func start() {
    window.makeKeyAndVisible()
    showChartListScreen()
  }
  
  func showChartListScreen() {
    let viewController = ChartListViewController(charts: charts)
    viewController.delegate = self
    viewController.title = "Chart List"
    navigationController.pushViewController(viewController, animated: false)
  }
  
  func showChartScreen(for chart: Chart, title: String) {
    let viewController = ChartViewController(chart: chart, chartName: title)
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
