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

class XAxisView: UIView {
  private var configuredForBounds: CGRect = .zero
  private var scrollView = UIScrollView()
  private var contentView = UIView()
  private var totalWindowSize: Double = 0
  private var currentWindowSize: Double = 0
  private var contentViewWidthConstraint: NSLayoutConstraint?
  private var xAxis: XAxis?
  private var labels: [UILabel] = []
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    setupScrollView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if bounds != configuredForBounds, let xAxis = xAxis {
      configure(xAxis: xAxis)
    }
  }
  
  func configure(xAxis: XAxis) {
    self.xAxis = xAxis
    
    guard !xAxis.allValues.isEmpty else { return }
    let oldWindowSize = currentWindowSize
    
    if !contentView.subviews.isEmpty {
      let totalSize = Double(xAxis.allValues.count)
      let diff = oldWindowSize - xAxis.windowSize * totalSize
      if diff < 1e-4, diff >= 0 {
        let currentContentWidth = contentViewWidthConstraint?.constant ?? 0
        let offset = currentContentWidth * CGFloat(xAxis.leftSegmentationLimit)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        for label in labels {
          let labelFrame = convert(label.frame, from: scrollView)
          label.isHidden = labelFrame.minX < 0 || labelFrame.maxX > bounds.width
        }
        configuredForBounds = bounds
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
    scrollView.setContentOffset(CGPoint(x: windowOffset, y: 0), animated: false)
    for label in labels {
      let labelFrame = convert(label.frame, from: scrollView)
      label.isHidden = labelFrame.minX < 0 || labelFrame.maxX > bounds.width
    }
    configuredForBounds = bounds
  }
  
  private func createLabel() -> UILabel {
    let label = UILabel()
    addSubview(label)
    label.textColor = UIColor.gray
    label.font = UIFont.systemFont(ofSize: 11, weight: .light)
    return label
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
