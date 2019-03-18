//
//  UIViewController+BackButton.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

extension UIViewController {
  func setDefaultBackButtonTitle() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}
