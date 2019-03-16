//
//  YAxisView.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let labelCount = 6
}

class YAxisView: UIView {
  private var shapeLayers: [CAShapeLayer] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(yAxis: YAxis) {
    for index in 0..<Constants.labelCount {
      let shapeLayer = shapeLayers[index]
      shapeLayer.path = path(index: index, stepPercentage: yAxis.step.percentageValue).cgPath
    }
  }
  
  private func setup() {
    for _ in 0..<Constants.labelCount {
      let shapeLayer = CAShapeLayer()
      shapeLayer.fillColor = UIColor.clear.cgColor
      shapeLayer.strokeColor = UIColor.lightGray.cgColor
      shapeLayer.lineWidth = 0.5
      shapeLayer.frame = bounds
      shapeLayers.append(shapeLayer)
      layer.addSublayer(shapeLayer)
    }
  }
  
  private func path(index: Int, stepPercentage: Double) -> UIBezierPath {
    let path = UIBezierPath()
    let start = CGPoint(x: 0, y: CGFloat(index) * CGFloat(stepPercentage) * bounds.height)
    path.move(to: start)
    let end = CGPoint(x: bounds.width, y: CGFloat(index) * CGFloat(stepPercentage) * bounds.height)
    path.addLine(to: end)
    return path
  }
}
