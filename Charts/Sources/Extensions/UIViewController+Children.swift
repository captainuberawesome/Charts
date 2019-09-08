//
//  UIViewController+Children.swift
//  Charts
//
//  Created by Daria Novodon on 08/09/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

extension UIViewController {
  func add(viewController: UIViewController, to view: UIView) {
    guard viewController.view.superview == nil else { return }
    addChild(viewController)
    if let childView = viewController.view {
      view.addSubview(childView)
      childView.translatesAutoresizingMaskIntoConstraints = false
      childView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
      childView.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
      childView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      childView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    viewController.didMove(toParent: self)
  }

  func remove(viewController: UIViewController) {
    guard viewController.view.superview != nil else { return }
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
  }
}
