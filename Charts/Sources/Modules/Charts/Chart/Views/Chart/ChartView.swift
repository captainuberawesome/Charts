//
//  ChartView.swift
//  Charts
//
//  Created by Daria Novodon on 15/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

// MARK: - XAxisTapData

struct XAxisTapData {
  let value: TimeInterval
  let index: Int
  let location: CGPoint
}

// MARK: - YAxisTapData

struct YAxisTapData {
  let value: YValue
  let location: CGPoint
}

// MARK: - ChartView

class ChartView: UIView {
  // MARK: - Properties
  
  private let chartSelectionBubbleView = ChartSelectionBubbleView()
  private let linesContainerView = UIView()
  private var lineViews: [LineView] = []
  private let yAxisView = YAxisView()
  private let xAxisView = XAxisView()
  private let backgroundLinesView = BackgroundLinesView()
  private var configuredForBounds: CGRect = .zero
  private var animationStartedDate: Date?
  private var handlePanGestureWorkItem: DispatchWorkItem?
  
  var animationsAllowed = false
  
  // MARK: - Callbacks
  
  var onNeedsReconfiguring: (() -> Void)?
  var onChartTapped: ((CGPoint) -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    yAxisView.addGestureRecognizer(ImmediatePanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
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
    chartSelectionBubbleView.removeFromSuperview()
    backgroundLinesView.removeVerticalLine()
    lineViews.forEach { $0.hideCircleView() }
    
    guard bounds.width > 0, bounds.height > 0 else {
      return
    }
    
    let xAxis = chart.xAxis
    let addLineViews = lineViews.isEmpty
    
    for (index, yAxis) in chart.yAxes.enumerated() {
      if addLineViews {
        let lineView = LineView(frame: linesContainerView.bounds, color: UIColor(hexString: yAxis.colorHex), lineWidth: 2.0)
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
    chartSelectionBubbleView.removeFromSuperview()
    backgroundLinesView.removeVerticalLine()
    lineViews.forEach { $0.hideCircleView() }
    
    guard bounds.width > 0, bounds.height > 0 else {
      return
    }
    
    guard animationsAllowed else {
      configure(chart: chart)
      return
    }
    
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
  
  func addSelectionBubble(location: CGPoint, chart: Chart) {
    guard let xAxisTapData = xAxisView.xValue(for: convert(location, to: xAxisView), xAxis: chart.xAxis) else { return }
    var yValues: [YAxisTapData] = []
    for yAxis in chart.toggledYAxes {
      let yValue = yAxis.allValuesNormalizedToSegment[xAxisTapData.index]
      let location = yAxisView.location(forValue: yValue, xCoordinate: xAxisTapData.location.x)
      yValues.append(YAxisTapData(value: yValue, location: location))
    }
    addSubview(chartSelectionBubbleView)
    chartSelectionBubbleView.onBubbleTapped = { [unowned self] in
      self.chartSelectionBubbleView.removeFromSuperview()
      self.backgroundLinesView.removeVerticalLine()
      self.lineViews.forEach { $0.hideCircleView() }
    }
    let bubbleWidth: CGFloat = 100
    chartSelectionBubbleView.frame = CGRect(origin: .zero,
                                            size: CGSize(width: bubbleWidth, height: linesContainerView.bounds.height))
    chartSelectionBubbleView.center = CGPoint(x: xAxisTapData.location.x, y: linesContainerView.center.y)
    if chartSelectionBubbleView.frame.origin.x < -5 {
      chartSelectionBubbleView.frame.origin = CGPoint(x: -5, y: chartSelectionBubbleView.frame.origin.y)
    }
    if chartSelectionBubbleView.frame.maxX > bounds.width + 5 {
      chartSelectionBubbleView.frame.origin = CGPoint(x: bounds.width + 5 - bubbleWidth,
                                                      y: chartSelectionBubbleView.frame.origin.y)
    }
    backgroundLinesView.addVerticalLine(atXCoordinate: xAxisTapData.location.x)
    let visibleLineViews = lineViews.filter { $0.isVisible }
    for (index, tapData) in yValues.enumerated() {
      let lineView = visibleLineViews[index]
      lineView.showCircleView(for: tapData)
    }
    chartSelectionBubbleView.configure(time: xAxisTapData.value, tapData: yValues)
  }
  
  // MARK: - Setup
  
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
  
  // MARK: - Actions
  
  @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
    var position = gestureRecognizer.location(in: yAxisView)
    if position.x < 0 {
      position.x = 0
    }
    if position.x > yAxisView.bounds.width {
      position.x = yAxisView.bounds.width
    }
    handlePanGestureWorkItem?.cancel()
    let work = DispatchWorkItem { [position] in
      self.onChartTapped?(position)
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: work)
    handlePanGestureWorkItem = work
  }
}
