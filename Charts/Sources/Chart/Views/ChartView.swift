//
//  ChartView.swift
//  Charts
//
//  Created by Daria Novodon on 15/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartView: UIView {
  private var lineViews: [LineView] = []
  private let yAxisView = YAxisView()
  private var configuredForBounds: CGRect = .zero
  
  var onNeedsReconfiguring: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    yAxisView.frame = bounds
    if bounds != configuredForBounds {
      onNeedsReconfiguring?()
    }
  }
  
  func configure(chart: Chart) {
    guard bounds.width > 0, bounds.height > 0 else {
      return
    }
    
    lineViews.forEach { $0.removeFromSuperview() }
    lineViews = []
    
    let xAxis = chart.xAxis
    for yAxis in chart.yAxes {
      var points: [CGPoint] = []
      for (x, y) in zip(xAxis.segmentedValues, yAxis.segmentedValues) {
        let point = CGPoint(x: x.percentageValue * Double(bounds.width), y: y.percentageValue * Double(bounds.height))
        points.append(point)
      }
      let lineView = LineView(frame: bounds, points: points, color: UIColor.init(hexString: yAxis.colorHex), lineWidth: 2.0)
      lineViews.append(lineView)
      addSubview(lineView)
    }
    
    if let yAxis = chart.yAxes.first(where: { $0.isEnabled }) {
      yAxisView.configure(yAxis: yAxis)
    }
    configuredForBounds = bounds
  }
  
  func animate(to chart: Chart) {
    let xAxis = chart.xAxis
    for (index, yAxis) in chart.yAxes.enumerated() {
      var points: [CGPoint] = []
      for (x, y) in zip(xAxis.segmentedValues, yAxis.segmentedValues) {
        let point = CGPoint(x: x.percentageValue * Double(bounds.width), y: y.percentageValue * Double(bounds.height))
        points.append(point)
      }
      let lineView = lineViews[index]
      lineView.animate(to: points)
    }
  }
  
  private func setup() {
    addSubview(yAxisView)
    yAxisView.frame = bounds
  }
}
