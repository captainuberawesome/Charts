//
//  XAxisView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let maxLabelCount = 6
}

class XAxisView: UIView, ViewScrollable, DayNightViewConfigurable {
  
  // MARK: - Properties
  
  private var configuredForBounds: CGRect = .zero
  private var totalWindowSize: Double = 0
  private var currentWindowSize: Double = 0
  private var labels: [UILabel] = []
  private let dayNightModeToggler: DayNightModeToggler
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "MMM d"
    return formatter
  }()
  
  var scrollView = UIScrollView()
  var contentView = UIView()
  var contentViewWidthConstraint: NSLayoutConstraint?
  
   // MARK: - Init
  
  init(dayNightModeToggler: DayNightModeToggler, frame: CGRect = .zero) {
    self.dayNightModeToggler = dayNightModeToggler
    super.init(frame: frame)
    clipsToBounds = true
    setupScrollView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
   // MARK: - Public methods
  
  func configure(xAxis: XAxis) {
    guard !xAxis.allValues.isEmpty else { return }
    let oldWindowSize = currentWindowSize
    
    if !contentView.subviews.isEmpty {
      let totalSize = Double(xAxis.allValues.count)
      let diff = oldWindowSize - xAxis.windowSize * totalSize
      if diff < 1e-4, diff >= 0 {
        scrollToSegmentationLimit(xAxis: xAxis)
        return
      } else {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        labels = []
      }
    }
    
    totalWindowSize = Double(xAxis.allValues.count)
    currentWindowSize = xAxis.windowSize * totalWindowSize
    let contentWidth = bounds.width * (CGFloat(totalWindowSize) / CGFloat(currentWindowSize))
    contentViewWidthConstraint?.constant = contentWidth
    
    let step = bounds.width / CGFloat(Constants.maxLabelCount)
    for offset in stride(from: 20, to: contentWidth, by: step) {
      let percentageValue = offset / contentWidth
      guard let value = xAxis.interpolatedValue(for: Double(percentageValue)) else {
        continue
      }
      let label = createLabel()
      contentView.addSubview(label)
      let date = Date(timeIntervalSince1970: value)
      let stringValue = dateFormatter.string(from: date)
      label.text = stringValue
      label.sizeToFit()
      label.frame.origin = CGPoint(x: offset - 0.5 * label.frame.size.width,
                                   y: bounds.height - label.frame.size.height)
      labels.append(label)
    }
    
    let windowOffset = contentWidth / CGFloat(totalWindowSize - 1) * CGFloat(xAxis.leftSegmentationIndex)
    scroll(to: windowOffset)
  }
  
  func xValue(for position: CGPoint, xAxis: XAxis) -> XAxisTapData? {
    let xPosition = contentView.convert(position, from: self).x
    if let (value, index) = xAxis.nextValueAndIndex(for: Double(xPosition / contentView.bounds.width)) {
      let newPositionX = contentView.bounds.width * CGFloat(value.percentageValue)
      let newPosition = contentView.convert(CGPoint(x: newPositionX, y: position.y), to: self)
      guard newPosition.x >= 0 && newPosition.x <= bounds.width else {
        return nil
      }
      return XAxisTapData(value: value.actualValue, index: index, location: newPosition)
    }
    return nil
  }
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    for label in labels {
      label.textColor = dayNightModeToggler.dullestTextColor
    }
  }
  
   // MARK: - Private methods
  
  private func scrollToSegmentationLimit(xAxis: XAxis) {
    let currentContentWidth = contentViewWidthConstraint?.constant ?? 0
    let offset = currentContentWidth * CGFloat(xAxis.leftSegmentationLimit)
    scroll(to: offset)
  }
  
  private func scroll(to offset: CGFloat) {
    scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    for label in labels {
      let labelFrame = convert(label.frame, from: scrollView)
      label.isHidden = labelFrame.minX < 0 || labelFrame.maxX > bounds.width
    }
    configuredForBounds = bounds
  }
  
  private func createLabel() -> UILabel {
    let label = UILabel()
    addSubview(label)
    label.textColor = dayNightModeToggler.dullestTextColor
    label.font = UIFont.systemFont(ofSize: 11, weight: .light)
    return label
  }
}
