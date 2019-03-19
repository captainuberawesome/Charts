//
//  LineView.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class LineView: UIView, ViewScrollable, LineAnimating, DayNightViewConfigurable {
  // MARK: - Properties
  
  private let color: UIColor
  private let lineWidth: CGFloat
  private let circleView: CircleView
  private var totalWindowSize: Double = 0
  private var currentWindowSize: Double = 0
  private let dayNightModeToggler: DayNightModeToggler
  private (set) var isVisible = true
  
  var oldPoints: [CGPoint] = []
  var points: [CGPoint] = []
  var intermediatePoints: [CGPoint] = []
  var shapeLayer = CAShapeLayer()
  var displayLink: CADisplayLink?
  var startTime: CFAbsoluteTime?
  var isAnimating = false
  var animationCompletionClosure: (() -> Void)?
  
  var scrollView = UIScrollView()
  var contentView = UIView()
  var contentViewWidthConstraint: NSLayoutConstraint?
  
  // MARK: - Init
  
  init(frame: CGRect, dayNightModeToggler: DayNightModeToggler, color: UIColor, lineWidth: CGFloat = 1.0) {
    self.color = color
    self.lineWidth = lineWidth
    self.dayNightModeToggler = dayNightModeToggler
    circleView = CircleView(frame: CGRect(origin: .zero, size: CGSize(width: 8, height: 8)),
                            color: color, dayNightModeToggler: dayNightModeToggler)
    super.init(frame: frame)
    isOpaque = false
    
    addSubview(circleView)
    circleView.isHidden = true
    setupScrollView()
    
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = color.cgColor
    shapeLayer.lineWidth = lineWidth
    shapeLayer.frame = contentView.bounds
    contentView.layer.addSublayer(shapeLayer)
    contentView.clipsToBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shapeLayer.frame = contentView.bounds
    bringSubviewToFront(circleView)
  }
  
  // MARK: - Public methods
  
  func showCircleView(for tapData: YAxisTapData) {
    let center = convert(tapData.location, from: superview)
    circleView.center = center
    circleView.isHidden = false
  }
  
  func hideCircleView() {
    circleView.isHidden = true
  }
  
  func configure(xAxis: XAxis, yAxis: YAxis) {
    if let startTime = startTime {
      let elapsed = CFAbsoluteTimeGetCurrent() - startTime
      if elapsed < 0.2 {
        animationCompletionClosure = { [weak self, xAxis, yAxis] in
          self?.configure(xAxis: xAxis, yAxis: yAxis)
        }
        return
      }
    }
    
    isVisible = yAxis.isEnabled
    totalWindowSize = Double(xAxis.allValues.count)
    currentWindowSize = xAxis.windowSize * totalWindowSize
    let contentWidth = bounds.width * (CGFloat(totalWindowSize) / CGFloat(currentWindowSize))
    contentViewWidthConstraint?.constant = contentWidth
    
    let currentContentWidth = contentViewWidthConstraint?.constant ?? 0
    let offset = currentContentWidth * CGFloat(xAxis.leftSegmentationLimit)
    
    contentView.setNeedsLayout()
    contentView.layoutIfNeeded()
    updatePoints(xAxis: xAxis, yAxis: yAxis)
    shapeLayer.path = path(points: points).cgPath
    scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
  }
  
  func reconfigureAnimated(xAxis: XAxis, yAxis: YAxis) {
    if let startTime = startTime {
      let elapsed = CFAbsoluteTimeGetCurrent() - startTime
      if elapsed < 0.2 {
        animationCompletionClosure = { [weak self, xAxis, yAxis] in
          self?.configure(xAxis: xAxis, yAxis: yAxis)
        }
        return
      }
    }
    
    oldPoints = isAnimating ? intermediatePoints : points
    updatePoints(xAxis: xAxis, yAxis: yAxis)
    
    startTime = CFAbsoluteTimeGetCurrent()
    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
    displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    
    isAnimating = true
    
    let animationClosure: ((_ hide: Bool) -> Void) = { hide in
      UIView.animate(withDuration: 0.2) {
        self.alpha = hide ? 0.0 : 1.0
      }
    }
    if !yAxis.isEnabled, isVisible {
      animationClosure(true)
    } else if yAxis.isEnabled, !isVisible {
      animationClosure(false)
    }
    isVisible = yAxis.isEnabled
    
    let currentContentWidth = contentViewWidthConstraint?.constant ?? 0
    let offset = currentContentWidth * CGFloat(xAxis.leftSegmentationLimit)
    scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
  }
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    circleView.configure(dayNightModeToggler: dayNightModeToggler)
  }
  
  // MARK: - Private methods
  
  private func updatePoints(xAxis: XAxis, yAxis: YAxis) {
    var points: [CGPoint] = []
    for (xValue, yValue) in zip(xAxis.allValues, yAxis.allValuesNormalizedToSegment) {
      let yCoordinate = Double(contentView.bounds.height) - yValue.percentageValue * Double(contentView.bounds.height)
      let point = CGPoint(x: xValue.percentageValue * Double(contentView.bounds.width),
                          y: yCoordinate)
      points.append(point)
    }
    self.points = points
  }
  
  // MARK: - Actions
  
  @objc private func handleDisplayLink(displayLink: CADisplayLink) {
    animate(with: displayLink)
  }
}
