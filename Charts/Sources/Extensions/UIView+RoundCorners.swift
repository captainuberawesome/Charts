//
//  UIView+RoundCorners.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners,
                            cornerRadii: CGSize(width: radius, height: radius))
    let maskLayer = CAShapeLayer()
    maskLayer.frame = self.bounds
    maskLayer.path = path.cgPath
    self.layer.mask = maskLayer
  }
}
