//
//  ChartMiniatureView.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartMiniatureView: ViewWithTouchesOutside, DayNightViewConfigurable {
  // MARK: - Properties
  
  private var lineViews: [SimpleLineView] = []
  private var configuredForBounds: CGRect = .zero
  private let draggableView = DraggableView()
  
  var leftHandleValue: Double {
    get {
      return draggableView.leftHandleValue
    }
    set {
      draggableView.leftHandleValue = newValue
    }
  }
  
  var rightHandleValue: Double {
    get {
      return draggableView.rightHandleValue
    }
    set {
      draggableView.rightHandleValue = newValue
    }
  }
  
  // MARK: - Callbacks
  
  var onNeedsReconfiguring: (() -> Void)?
  var onLeftHandleValueChanged: ((Double) -> Void)?
  var onRightHandleValueChanged: ((Double) -> Void)?
  var onBothValueChanged: ((Double, Double) -> Void)?
  var onFinished: (() -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if bounds != configuredForBounds {
      onNeedsReconfiguring?()
    }
  }
  
  // MARK: - Public methods
  
  func configure(chart: Chart) {
    guard chart.xAxis.allValues.count > 1, bounds.width > 0, bounds.height > 0, bounds != configuredForBounds else {
      return
    }
    
    lineViews.forEach { $0.removeFromSuperview() }
    lineViews = []
    let xAxis = chart.xAxis
    for yAxis in chart.toggledYAxes {
      let points = createPointsForLines(xAxis: xAxis, yAxis: yAxis)
      let lineView = SimpleLineView(frame: bounds.inset(by: UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)),
                                    points: points, color: UIColor(hexString: yAxis.colorHex))
      lineView.clipsToBounds = true
      lineViews.append(lineView)
      addSubview(lineView)
    }
    configuredForBounds = bounds
    bringSubviewToFront(draggableView)
  }
  
  func animate(to chart: Chart) {
    guard chart.xAxis.allValues.count > 1 else { return }
    
    let xAxis = chart.xAxis
    for (index, yAxis) in chart.yAxes.enumerated() {
      let points = createPointsForLines(xAxis: xAxis, yAxis: yAxis)
      if index < lineViews.count {
        let lineView = lineViews[index]
        lineView.frame = bounds.inset(by: UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0))
        lineView.animate(to: points, isEnabled: yAxis.isEnabled)
      }
    }
  }
  
  func stopAnimation() {
    for lineView in lineViews {
      lineView.stopAnimation()
    }
  }
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    draggableView.configure(dayNightModeToggler: dayNightModeToggler)
    backgroundColor = dayNightModeToggler.miniatureChartBackgroundColor
  }
  
  // MARK: - Setup
  
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
  
  // MARK: - Private methods
  
  private func createPointsForLines(xAxis: XAxis, yAxis: YAxis) -> [CGPoint] {
    var points: [CGPoint] = []
    for (xValue, yValue) in zip(xAxis.allValues, yAxis.allValuesNormalized) {
      let yCoordinate = Double(bounds.height) - yValue.percentageValue * Double(bounds.height)
      let point = CGPoint(x: xValue.percentageValue * Double(bounds.width), y: yCoordinate)
      points.append(point)
    }
    return points
  }
}
