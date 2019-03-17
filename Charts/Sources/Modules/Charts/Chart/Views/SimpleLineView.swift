//
//  SimpleLineView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class SimpleLineView: UIView {
  private var points: [CGPoint]
  private let color: UIColor
  private let lineWidth: CGFloat
  private var shapeLayer = CAShapeLayer()
  
  init(frame: CGRect, points: [CGPoint], color: UIColor, lineWidth: CGFloat = 1.0) {
    self.points = points
    self.color = color
    self.lineWidth = lineWidth
    super.init(frame: frame)
    isOpaque = false
    
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.frame = bounds
    layer.addSublayer(shapeLayer)
    shapeLayer.path = path(points: points).cgPath
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shapeLayer.frame = bounds
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func path(points: [CGPoint]) -> UIBezierPath {
    let path = UIBezierPath()
    for (index, point) in points.enumerated() {
      if index == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
        path.move(to: point)
      }
    }
    return path
  }
}

