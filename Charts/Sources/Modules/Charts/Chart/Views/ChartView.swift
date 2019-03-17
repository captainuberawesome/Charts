//
//  ChartView.swift
//  Charts
//
//  Created by Daria Novodon on 15/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartView: UIView {
  private let linesContainerView = UIView()
  private var lineViews: [LineView] = []
  private let yAxisView = YAxisView()
  private let xAxisView = XAxisView()
  private let backgroundLinesView = BackgroundLinesView()
  private var configuredForBounds: CGRect = .zero
  private var animationStartedDate: Date?
  
  var onNeedsReconfiguring: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if bounds != configuredForBounds {
      onNeedsReconfiguring?()
    }
  }
  
  func configure(chart: Chart) {
    guard bounds.width > 0, bounds.height > 0 else {
      return
    }
    
    let xAxis = chart.xAxis
    let addLineViews = lineViews.isEmpty
    
    for (index, yAxis) in chart.toggledYAxes.enumerated() {
      if addLineViews {
        let lineView = LineView(frame: linesContainerView.bounds, color: UIColor.init(hexString: yAxis.colorHex), lineWidth: 2.0)
        lineViews.append(lineView)
        linesContainerView.addSubview(lineView)
        lineView.frame = linesContainerView.bounds
        lineView.configure(xAxis: xAxis, yAxis: yAxis)
      } else {
        let lineView = lineViews[index]
        lineView.frame = linesContainerView.bounds
        lineView.configure(xAxis: xAxis, yAxis: yAxis)
      }
    }
    
    if let yAxis = chart.yAxes.first(where: { $0.isEnabled }) {
      yAxisView.layoutIfNeeded()
      yAxisView.configure(yAxis: yAxis)
      backgroundLinesView.layoutIfNeeded()
      backgroundLinesView.configure(yAxis: yAxis)
    }
    xAxisView.configure(xAxis: chart.xAxis)
    configuredForBounds = bounds
  }
  
  func animate(to chart: Chart) {    
    let xAxis = chart.xAxis
    for (index, yAxis) in chart.yAxes.enumerated() {
      let lineView = lineViews[index]
      lineView.frame = linesContainerView.bounds
      lineView.reconfigureAnimated(xAxis: xAxis, yAxis: yAxis)
    }
    if let yAxis = chart.yAxes.first(where: { $0.isEnabled }) {
      yAxisView.layoutIfNeeded()
      yAxisView.configure(yAxis: yAxis, animateIfNeeded: true)
      backgroundLinesView.layoutIfNeeded()
      backgroundLinesView.animate(yAxis: yAxis)
    }
    xAxisView.configure(xAxis: chart.xAxis)
  }
  
  private func setup() {
    let topOffset: CGFloat = 0
    let bottomOffset: CGFloat = -17
    
    addSubview(backgroundLinesView)
    backgroundLinesView.translatesAutoresizingMaskIntoConstraints = false
    backgroundLinesView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    backgroundLinesView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    backgroundLinesView.topAnchor.constraint(equalTo: topAnchor, constant: topOffset).isActive = true
    backgroundLinesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomOffset).isActive = true
    
    addSubview(linesContainerView)
    linesContainerView.translatesAutoresizingMaskIntoConstraints = false
    linesContainerView.leadingAnchor.constraint(equalTo: backgroundLinesView.leadingAnchor).isActive = true
    linesContainerView.trailingAnchor.constraint(equalTo: backgroundLinesView.trailingAnchor).isActive = true
    linesContainerView.topAnchor.constraint(equalTo: backgroundLinesView.topAnchor).isActive = true
    linesContainerView.bottomAnchor.constraint(equalTo: backgroundLinesView.bottomAnchor).isActive = true
    linesContainerView.clipsToBounds = true
    
    addSubview(yAxisView)
    yAxisView.translatesAutoresizingMaskIntoConstraints = false
    yAxisView.leadingAnchor.constraint(equalTo: backgroundLinesView.leadingAnchor).isActive = true
    yAxisView.trailingAnchor.constraint(equalTo: backgroundLinesView.trailingAnchor).isActive = true
    yAxisView.topAnchor.constraint(equalTo: backgroundLinesView.topAnchor).isActive = true
    yAxisView.bottomAnchor.constraint(equalTo: backgroundLinesView.bottomAnchor).isActive = true
    
    addSubview(xAxisView)
    xAxisView.translatesAutoresizingMaskIntoConstraints = false
    xAxisView.leadingAnchor.constraint(equalTo: backgroundLinesView.leadingAnchor).isActive = true
    xAxisView.trailingAnchor.constraint(equalTo: backgroundLinesView.trailingAnchor).isActive = true
    xAxisView.topAnchor.constraint(equalTo: backgroundLinesView.bottomAnchor).isActive = true
    xAxisView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
}
