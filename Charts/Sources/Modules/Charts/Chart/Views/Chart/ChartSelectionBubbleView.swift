//
//  ChartSelectionBubbleView.swift
//  Charts
//
//  Created by Daria Novodon on 17/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartSelectionBubbleView: UIView {
  // MARK: - Properties
  
  private let bubbleView = BubbleView()
  
  var calculatedWidth: CGFloat {
    return bubbleView.calculatedWidth
  }
  
  // MARK: - Callbacks
  
  var onBubbleTapped: (() -> Void)?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Overrides
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    for subview in subviews {
      let newPoint = convert(point, to: subview)
      if subview.point(inside: newPoint, with: event) && subview.isUserInteractionEnabled && !subview.isHidden {
        return true
      }
    }
    return false
  }
  
  // MARK: - Public methods
  
  func configure(time: TimeInterval, tapData: [YAxisTapData]) {
    bubbleView.configure(time: time, values: tapData.compactMap { $0.value })
    bubbleView.layoutIfNeeded()
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(bubbleView)
    bubbleView.translatesAutoresizingMaskIntoConstraints = false
    bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    bubbleView.backgroundColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 245 / 255, alpha: 1)
    bubbleView.layer.cornerRadius = 5
    bubbleView.isUserInteractionEnabled = true
    bubbleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
  }
  
  // MARK: - Actions
  
  @objc private func handleTap() {
    onBubbleTapped?()
  }
}
