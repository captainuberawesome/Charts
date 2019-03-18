//
//  LineView.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let animationDuration: TimeInterval = 0.2
}

class LineView: UIView {
  private var points: [CGPoint] = []
  private let color: UIColor
  private let lineWidth: CGFloat
  private var shapeLayer = CAShapeLayer()
  private var displayLink: CADisplayLink?
  private var startTime: CFAbsoluteTime?
  private var intermediatePoints: [CGPoint] = []
  private var oldPoints: [CGPoint] = []
  private var scrollView = UIScrollView()
  private let circleView: CircleView
  private var contentView = UIView()
  private var totalWindowSize: Double = 0
  private var currentWindowSize: Double = 0
  private var contentViewWidthConstraint: NSLayoutConstraint?
  private var isAnimating = false
  private (set) var isVisible = true
  
  init(frame: CGRect, color: UIColor, lineWidth: CGFloat = 1.0) {
    self.color = color
    self.lineWidth = lineWidth
    circleView = CircleView(frame: CGRect(origin: .zero, size: CGSize(width: 8, height: 8)), color: color)
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    shapeLayer.frame = contentView.bounds
    bringSubviewToFront(circleView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func showCircleView(for tapData: YAxisTapData) {
    let center = convert(tapData.location, from: superview)
    circleView.center = center
    circleView.isHidden = false
  }
  
  func hideCircleView() {
    circleView.isHidden = true
  }
  
  func configure(xAxis: XAxis, yAxis: YAxis) {
    guard isVisible else { return }
    isVisible = yAxis.isEnabled
    totalWindowSize = Double(xAxis.allValues.count)
    currentWindowSize = xAxis.windowSize * totalWindowSize
    let contentWidth = bounds.width * (CGFloat(totalWindowSize) / CGFloat(currentWindowSize))
    contentViewWidthConstraint?.constant = contentWidth
    contentView.setNeedsLayout()
    contentView.layoutIfNeeded()

    if isAnimating {
      startTime = CFAbsoluteTimeGetCurrent()
      oldPoints = intermediatePoints
      updatePoints(xAxis: xAxis, yAxis: yAxis)
    } else {
      updatePoints(xAxis: xAxis, yAxis: yAxis)
      shapeLayer.path = path(points: points).cgPath
    }
    
    let currentContentWidth = contentViewWidthConstraint?.constant ?? 0
    let offset = currentContentWidth * CGFloat(xAxis.leftSegmentationLimit)
    scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
  }
  
  func reconfigureAnimated(xAxis: XAxis, yAxis: YAxis) {
    oldPoints = isAnimating ? intermediatePoints : points
    isAnimating = true
    updatePoints(xAxis: xAxis, yAxis: yAxis)
    startTime = CFAbsoluteTimeGetCurrent()
    displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(displayLink:)))
    displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    
    let animationClosure: ((_ hide: Bool) -> Void) = { hide in
      UIView.animate(withDuration: 0.2, animations: {
        self.alpha = hide ? 0.0 : 1.0
      })
    }
    if !yAxis.isEnabled, isVisible {
      animationClosure(true)
    } else if yAxis.isEnabled, !isVisible {
      animationClosure(false)
    }
    isVisible = yAxis.isEnabled
  }
  
  private func updatePoints(xAxis: XAxis, yAxis: YAxis) {
    var points: [CGPoint] = []
    for (x, y) in zip(xAxis.allValues, yAxis.allValuesNormalizedToSegment) {
      let yCoordinate = Double(contentView.bounds.height) - y.percentageValue * Double(contentView.bounds.height)
      let point = CGPoint(x: x.percentageValue * Double(contentView.bounds.width),
                          y: yCoordinate)
      points.append(point)
    }
    self.points = points
  }
  
  private func path(points: [CGPoint]) -> UIBezierPath {
    let path = UIBezierPath()
    path.lineJoinStyle = .round
    path.lineCapStyle = .butt
    for (index, point) in points.enumerated() {
      if index == 0 {
        path.move(to: point)
      } else {
        path.addLine(to: point)
      }
    }
    return path
  }
  
  private func path(between first: [CGPoint], second: [CGPoint], percentage: Double) -> UIBezierPath {
    var points: [CGPoint] = []
    for index in 0..<min(first.count, second.count) {
      let firstPoint = first[index]
      let secondPoint = second[index]
      let x = firstPoint.x + CGFloat(percentage) * (secondPoint.x - firstPoint.x)
      let y = firstPoint.y + CGFloat(percentage) * (secondPoint.y - firstPoint.y)
      points.append(CGPoint(x: x, y: y))
    }
    intermediatePoints = points
    return path(points: points)
  }
  
  @objc private func handleDisplayLink(displayLink: CADisplayLink) {
    guard let startTime = startTime else { return }
    let elapsed = CFAbsoluteTimeGetCurrent() - startTime
    let percent = elapsed / Constants.animationDuration
    
    guard percent < 1 else {
      shapeLayer.path = path(points: points).cgPath
      displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
      isAnimating = false
      self.startTime = nil
      return
    }
    
    let newPath = path(between: oldPoints, second: points, percentage: percent)
    shapeLayer.path = newPath.cgPath
  }
  
  private func setupScrollView() {
    addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.isUserInteractionEnabled = false
    
    scrollView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    contentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
    contentViewWidthConstraint?.isActive = true
  }
}

private class CircleView: UIView {
  private let innerCircleView = UIView()
  
  init(frame: CGRect, color: UIColor) {
    super.init(frame: frame)
    backgroundColor = color
    layer.cornerRadius = bounds.width * 0.5
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    innerCircleView.frame = bounds.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
  }
  
  private func setup() {
    addSubview(innerCircleView)
    innerCircleView.backgroundColor = .white
    innerCircleView.frame = bounds.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    innerCircleView.layer.cornerRadius = innerCircleView.bounds.width * 0.5
  }
}
