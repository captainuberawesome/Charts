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
  static let spaceBetweenLabels: CGFloat = 14
}

class LabelContainer {
  var isDisappearing = false
  let label: UILabel
  let valueIndex: Int
  var frame: CGRect {
    get {
      return label.frame
    }
    set {
      label.frame = frame
    }
  }
  
  init(label: UILabel, valueIndex: Int) {
    self.label = label
    self.valueIndex = valueIndex
  }
}


class XAxisView: UIView, ViewScrollable, DayNightViewConfigurable {
  
  // MARK: - Properties
  
  private var configuredForBounds: CGRect = .zero
  private var totalWindowSize: Double = 0
  private var currentWindowSize: Double = 0
  private var labels: [LabelContainer] = []
  private var alphaAdjustmentWork: DispatchWorkItem?
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
    var oldLabels = labels
    
    if !contentView.subviews.isEmpty {
      let totalSize = Double(xAxis.allValues.count)
      let diff = oldWindowSize - xAxis.windowSize * totalSize
      if abs(diff) < 1e-4 {
        scrollToSegmentationLimit(xAxis: xAxis)
        return
      } else {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        labels = []
      }
    }
    
    totalWindowSize = Double(xAxis.allValues.count)
    let newWindowSize = xAxis.windowSize * totalWindowSize
    let contentWidth = bounds.width * (CGFloat(totalWindowSize) / CGFloat(newWindowSize))
    if contentWidth >= bounds.width  {
      currentWindowSize = newWindowSize
      contentViewWidthConstraint?.constant = contentWidth
    } else {
      return
    }

    let windowOffset = contentWidth / CGFloat(totalWindowSize - 1) * CGFloat(xAxis.leftSegmentationIndex)
    guard scrollView.bounds.width > 0 else { return }

    let labelsCount = Int(round((contentWidth / scrollView.bounds.width) * CGFloat(Constants.maxLabelCount)))
    var step = Int(round((Double(xAxis.allValues.count) / Double(labelsCount))))
    if !isPowerOfTwo(number: step) {
      step = Int(pow(2, ceil(log2(Double(step)) - 1)))
    }
    if step == 0 {
      step = 1
    }
    
    let newlabelCount = Int(floor(Double(xAxis.allValues.count) / Double(step)))
    oldLabels = newlabelCount == oldLabels.count ? oldLabels : []
    
    var index = 0
    addLabel(at: 0, xAxis: xAxis)
    while index < xAxis.allValues.count {
      index += step
      addLabel(at: index, xAxis: xAxis, oldLabels: oldLabels)
    }
    
    var minAlpha: CGFloat = 1
    for (index, label) in labels.enumerated() {
      if index == 0 || index + 1 == labels.count {
        continue
      }
      if label.label.alpha < minAlpha {
        minAlpha = label.label.alpha
      }
    }
    
    scroll(to: windowOffset, hideLabels: false)
    
    let firstIndex = labels.enumerated().first(where: {
      !$0.element.isDisappearing && !$0.element.label.isHidden && $0.element.label.alpha == 1
    })?.offset ?? 0
    let secondIndex = labels.enumerated().first(where: {
      !$0.element.isDisappearing && !$0.element.label.isHidden && $0.element.label.alpha == 1
        && $0.offset != firstIndex
    })?.offset ?? 0
    
    let adjustedStep = secondIndex - firstIndex
    var indices: [Int] = []
    if adjustedStep > 0 {
      for index in stride(from: 0, to: labels.count, by: adjustedStep) {
        indices.append(index)
      }
      for (index, label) in labels.enumerated() {
        if !indices.contains(index) {
          label.isDisappearing = true
        }
      }
    }

    labels.filter({ $0.isDisappearing }).forEach { $0.label.alpha = minAlpha }
    
    alphaAdjustmentWork?.cancel()
    let work = DispatchWorkItem { [weak self] in
      self?.adjustAlpha()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
    alphaAdjustmentWork = work
  }
  
  func adjustAlpha(animate: Bool = true) {
    let duration: TimeInterval = animate ? 0.2 : 0
    for (index, label) in labels.enumerated() {
      if index != 0 {
        label.label.isHidden = false
      }
      if label.label.alpha <= 0.4 {
        UIView.animate(withDuration: duration) {
          label.label.alpha = 0
        }
      } else {
        UIView.animate(withDuration: duration) {
          label.label.alpha = 1
        }
      }
      hideLabelIfNeeded(label, index: index)
    }
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
      label.label.textColor = dayNightModeToggler.dullestTextColor
    }
  }
  
   // MARK: - Private methods
  
  private func addLabel(at index: Int, xAxis: XAxis, oldLabels: [LabelContainer] = []) {
    guard index < xAxis.allValues.count else {
      return
    }
    let newWindowSize = xAxis.windowSize * totalWindowSize
    let contentWidth = bounds.width * (CGFloat(totalWindowSize) / CGFloat(newWindowSize))
    let value = xAxis.allValues[index]
    let percentageValue = value.percentageValue
    let offset = CGFloat(percentageValue) * contentWidth
    let label = createLabel()
    contentView.addSubview(label)
    let date = Date(timeIntervalSince1970: value.actualValue)
    let stringValue = dateFormatter.string(from: date)
    label.text = stringValue
    label.sizeToFit()
    label.frame.origin = CGPoint(x: offset - 0.5 * label.frame.size.width,
                                 y: bounds.height - label.frame.size.height)
    let labelContainer = LabelContainer(label: label, valueIndex: index)
    
    let firstIndex = labels.enumerated().first(where: {
      !$0.element.isDisappearing
    })?.element.valueIndex ?? 0
    let secondIndex = labels.enumerated().first(where: {
      !$0.element.isDisappearing && $0.element.valueIndex != firstIndex
    })?.element.valueIndex ?? 0
    
    let step = secondIndex - firstIndex
    
    var notDivisibleByStep = true
    if step > 1 {
      notDivisibleByStep = index % step != 0
    }
    
    let nonDisappearing = labels.filter { !$0.isDisappearing }
    if let previousLabel = nonDisappearing.last, notDivisibleByStep {
      var alpha = (label.frame.origin.x - previousLabel.frame.maxX) / Constants.spaceBetweenLabels
      if alpha < 0 {
        alpha = 0
      }
      label.alpha = alpha
      if alpha < 0.9 {
        labelContainer.isDisappearing = true
      } else {
        labelContainer.isDisappearing = false
      }
    }
    
    if label.frame.minX < 0.5 * Constants.spaceBetweenLabels {
      label.alpha = 1 - label.frame.minX / 0.5 * Constants.spaceBetweenLabels
    }
    
    if label.frame.maxX + 0.5 * Constants.spaceBetweenLabels > contentWidth {
      label.alpha = 1 - (contentWidth - label.frame.maxX) / 0.5 * Constants.spaceBetweenLabels
    }
    
    if index == 0 {
      label.alpha = 0
    }
    
    labels.append(labelContainer)
  }
  
  private func hideLabelIfNeeded(_ label: LabelContainer, index: Int) {
    let labelFrame = convert(label.frame, from: scrollView)
    let outOfBounds = labelFrame.minX < 0 || labelFrame.maxX > bounds.width
    if index == 0 && outOfBounds {
      label.label.isHidden = true
    } else if outOfBounds && (labelFrame.minX < 0 && labelFrame.maxX > 0
      || labelFrame.minX < bounds.width && labelFrame.maxX > bounds.width) {
      label.label.isHidden = true
    } else {
      label.label.isHidden = false
    }
  }
  
  private func scrollToSegmentationLimit(xAxis: XAxis) {
    let currentContentWidth = contentViewWidthConstraint?.constant ?? 0
    let offset = currentContentWidth * CGFloat(xAxis.leftSegmentationLimit)
    scroll(to: offset)
  }
  
  private func scroll(to offset: CGFloat, hideLabels: Bool = true) {
    scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    if hideLabels {
      for (index, label) in labels.enumerated() {
        hideLabelIfNeeded(label, index: index)
      }
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
  
  private func isPowerOfTwo(number: Int) -> Bool {
    return (number != 0) && ((number & (number - 1)) == 0)
  }
}
