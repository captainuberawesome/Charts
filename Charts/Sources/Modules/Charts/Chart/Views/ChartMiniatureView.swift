//
//  ChartMiniatureView.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartMiniatureView: UIView {
  private var lineViews: [SimpleLineView] = []
  private var configuredForBounds: CGRect = .zero
  private let draggableView = DraggableView()
  
  var onNeedsReconfiguring: (() -> Void)?
  var onLeftHandleValueChanged: ((Double) -> Void)?
  var onRightHandleValueChanged: ((Double) -> Void)?
  var onBothValueChanged: ((Double, Double) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
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
  
  private func setup() {
    addSubview(draggableView)
    draggableView.translatesAutoresizingMaskIntoConstraints = false
    draggableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    draggableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    draggableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    draggableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    draggableView.onLeftHandleValueChanged = { [weak self] value in
      self?.onLeftHandleValueChanged?(value)
    }
    draggableView.onRightHandleValueChanged = { [weak self] value in
      self?.onRightHandleValueChanged?(value)
    }
    draggableView.onBothValueChanged = { [weak self] leftValue, rightValue in
      self?.onBothValueChanged?(leftValue, rightValue)
    }
  }
  
  func configure(chart: Chart) {
    guard bounds.width > 0, bounds.height > 0 else {
      return
    }
    
    if bounds == configuredForBounds {
      return
    }
    
    lineViews.forEach { $0.removeFromSuperview() }
    lineViews = []
    let xAxis = chart.xAxis
    for yAxis in chart.toggledYAxes {
      var points: [CGPoint] = []
      for (x, y) in zip(xAxis.allValues, yAxis.allValues) {
        let yCoordinate = Double(bounds.height) - y.percentageValue * Double(bounds.height)
        let point = CGPoint(x: x.percentageValue * Double(bounds.width), y: yCoordinate)
        points.append(point)
      }
      let lineView = SimpleLineView(frame: bounds, points: points, color: UIColor.init(hexString: yAxis.colorHex))
      lineViews.append(lineView)
      addSubview(lineView)
    }
    configuredForBounds = bounds
    bringSubviewToFront(draggableView)
  }
  
  func animate(to chart: Chart) {
    let xAxis = chart.xAxis
    for (index, yAxis) in chart.yAxes.enumerated() {
      var points: [CGPoint] = []
      for (x, y) in zip(xAxis.allValues, yAxis.allValuesNormalized) {
        let yCoordinate = Double(bounds.height) - y.percentageValue * Double(bounds.height)
        let point = CGPoint(x: x.percentageValue * Double(bounds.width), y: yCoordinate)
        points.append(point)
      }
      let lineView = lineViews[index]
      lineView.frame = bounds
      lineView.animate(to: points, isEnabled: yAxis.isEnabled)
    }
  }
}
