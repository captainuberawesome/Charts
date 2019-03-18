//
//  ViewWithTouchesOutside.swift
//  Charts
//
//  Created by iOS Developer on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ViewWithTouchesOutside: UIView {
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    for subview in subviews.reversed() {
      let subPoint = subview.convert(point, from: self)
      if subview.point(inside: subPoint, with: event) {
        return true
      }
    }
    return bounds.contains(point)
  }
}
