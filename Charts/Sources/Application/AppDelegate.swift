//
//  AppDelegate.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  private lazy var chartsCoordinator: ChartsCoordinator = createChartsCoordinator()
  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    chartsCoordinator.start()
    return true
  }
  
  private func createChartsCoordinator() -> ChartsCoordinator {
    let windowFrame = UIScreen.main.bounds
    let newWindow = UIWindow(frame: windowFrame)
    self.window = newWindow
    return ChartsCoordinator(window: newWindow)
  }
}
