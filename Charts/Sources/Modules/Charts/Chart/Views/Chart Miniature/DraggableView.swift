//
//  DraggableView.swift
//  Charts
//
//  Created by Daria Novodon on 15/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

private struct Constants {
  static let handleWidth: CGFloat = 11
  static let iconHeight: CGFloat = 10
  static let iconWidth: CGFloat = 5.5
}

class DraggableView: UIView, DayNightViewConfigurable {
  // MARK: - Properties
  
  private let leftEdgeView = UIView()
  private let leftIconView = UIImageView(image: #imageLiteral(resourceName: "chevron-left"))
  private let leftEdgeDraggingView = UIView()
  private let rightEdgeView = UIView()
  private let rightIconView = UIImageView(image: #imageLiteral(resourceName: "chevron-right"))
  private let rightEdgeDraggingView = UIView()
  private let centerDraggingView = UIView()
  private let topSeparator = UIView()
  private let bottomSeparator = UIView()
  private let leftDimmingView = UIView()
  private let rightDimmingView = UIView()
  private let leftDraggingThrottler = Throttler(mustRunOnceInInterval: 0.01)
  private let rightDraggingThrottler = Throttler(mustRunOnceInInterval: 0.01)
  private var ignoreValueChange = false
  private var updatedSubviewsForBounds: CGRect = .zero
  private var centerDraggingViewWidth: CGFloat = 0
  
  private var leftEdgeViewOriginX: CGFloat = 0 {
    willSet {
      guard !ignoreValueChange, abs(newValue - leftEdgeViewOriginX) > 0.01 else {
        return
      }
      leftDraggingThrottler.addWork { [weak self] in
        guard let self = self else { return }
        self.onLeftHandleValueChanged?(Double(newValue / self.bounds.width))
      }
    }
  }
  private var rightEdgeViewMaxX: CGFloat = 0 {
    willSet {
      guard !ignoreValueChange, abs(newValue - rightEdgeViewMaxX) > 0.01 else {
        return
      }
      rightDraggingThrottler.addWork { [weak self] in
        guard let self = self else { return }
        self.onRightHandleValueChanged?(Double(newValue / self.bounds.width))
      }
    }
  }
  
  var leftHandleValue: Double {
    get {
      return Double(leftEdgeView.frame.minX / bounds.width)
    }
    set {
      ignoreValueChange = true
      leftEdgeViewOriginX = CGFloat(newValue) * bounds.width
      updateSubviewFrames()
      ignoreValueChange = false
    }
  }
  
  var rightHandleValue: Double {
    get {
      return Double(rightEdgeView.frame.maxX / bounds.width)
    }
    set {
      ignoreValueChange = true
      rightEdgeViewMaxX = CGFloat(newValue) * bounds.width
      updateSubviewFrames()
      ignoreValueChange = false
    }
  }
  
  // MARK: - Callbacks
  
  var onBothValueChanged: ((Double, Double) -> Void)?
  var onRightHandleValueChanged: ((Double) -> Void)?
  var onLeftHandleValueChanged: ((Double) -> Void)?
  
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
    guard bounds.width > 0, bounds.height > 0 else { return }
    if rightEdgeViewMaxX == 0 {
      rightEdgeViewMaxX = bounds.size.width
    }
    
    if bounds != updatedSubviewsForBounds {
      updatedSubviewsForBounds = bounds
      updateSubviewFrames()
    }
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if leftEdgeDraggingView.frame.contains(point)
      || rightEdgeDraggingView.frame.contains(point) {
      return true
    }
    return bounds.contains(point)
  }
  
  // MARK: - Public methods
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    let backgroundColor = dayNightModeToggler.draggableViewHandleColor
    let overlayColor = dayNightModeToggler.draggableViewOverlayColor
    
    leftEdgeView.backgroundColor = backgroundColor
    rightEdgeView.backgroundColor = backgroundColor
    topSeparator.backgroundColor = backgroundColor
    bottomSeparator.backgroundColor = backgroundColor
    leftDimmingView.backgroundColor = overlayColor
    rightDimmingView.backgroundColor = overlayColor
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(leftDimmingView)
    addSubview(rightDimmingView)
    addSubview(leftEdgeView)
    addSubview(leftIconView)
    addSubview(rightEdgeView)
    addSubview(rightIconView)
    addSubview(centerDraggingView)
    addSubview(leftEdgeDraggingView)
    addSubview(rightEdgeDraggingView)
    addSubview(topSeparator)
    addSubview(bottomSeparator)
    
    leftIconView.tintColor = .white
    leftIconView.frame.size = CGSize(width: Constants.iconWidth, height: Constants.iconHeight)
    leftEdgeView.contentMode = .scaleAspectFit
    rightIconView.tintColor = .white
    rightIconView.frame.size = CGSize(width: Constants.iconWidth, height: Constants.iconHeight)
    rightIconView.contentMode = .scaleAspectFit
    
    leftEdgeDraggingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragLeft(_:))))
    rightEdgeDraggingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragRight(_:))))
    centerDraggingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragCenter(_:))))
  }
  
  // MARK: - Private methods
  
  private func updateSubviewFrames() {
    leftEdgeView.frame = CGRect(x: leftEdgeViewOriginX, y: 0, width: Constants.handleWidth, height: bounds.size.height)
    leftEdgeView.roundCorners(corners: [.bottomLeft, .topLeft], radius: 2)
    leftIconView.center = leftEdgeView.center
    rightEdgeView.frame = CGRect(x: rightEdgeViewMaxX - Constants.handleWidth, y: 0,
                                 width: Constants.handleWidth, height: bounds.size.height)
    rightEdgeView.roundCorners(corners: [.topRight, .bottomRight], radius: 2)
    rightIconView.center = rightEdgeView.center
    topSeparator.frame = CGRect(x: leftEdgeView.frame.maxX,
                                y: 0,
                                width: rightEdgeView.frame.minX - leftEdgeView.frame.maxX,
                                height: 1)
    bottomSeparator.frame = CGRect(x: leftEdgeView.frame.maxX,
                                   y: bounds.size.height - 1,
                                   width: rightEdgeView.frame.minX - leftEdgeView.frame.maxX,
                                   height: 1)
    let isFullyCollapsed = abs(leftEdgeViewOriginX + 2 * Constants.handleWidth - rightEdgeViewMaxX) < 1
    let draggingViewsWidth: CGFloat = isFullyCollapsed ? 2 * Constants.handleWidth : 3 * Constants.handleWidth
    leftEdgeDraggingView.frame.size = CGSize(width: draggingViewsWidth, height: leftEdgeView.frame.height)
    leftEdgeDraggingView.center = leftEdgeView.center
    rightEdgeDraggingView.frame.size = leftEdgeDraggingView.frame.size
    rightEdgeDraggingView.center = rightEdgeView.center
    let centerWidth = rightEdgeView.frame.origin.x - leftEdgeView.frame.maxX
    centerDraggingView.frame = CGRect(x: leftEdgeView.frame.maxX, y: 0,
                                      width: centerWidth, height: bounds.size.height)
    leftDimmingView.frame = CGRect(x: 0, y: 1,
                                   width: leftEdgeView.frame.minX + Constants.handleWidth,
                                   height: bounds.size.height - 2)
    rightDimmingView.frame = CGRect(x: rightEdgeView.frame.maxX - Constants.handleWidth, y: 1,
                                    width: bounds.size.width - rightEdgeView.frame.maxX + Constants.handleWidth,
                                    height: bounds.size.height - 2)
  }
  
  // MARK: - Actions
  
  @objc private func dragLeft(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began, .changed:
      let translation = gestureRecognizer.translation(in: self)
      var newOriginX = max(leftEdgeView.frame.origin.x + translation.x, 0)
      newOriginX = min(newOriginX, rightEdgeView.frame.origin.x - Constants.handleWidth)
      leftEdgeViewOriginX = newOriginX
      updateSubviewFrames()
      gestureRecognizer.setTranslation(.zero, in: self)
    default:
      break
    }
  }
  
  @objc private func dragRight(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began, .changed:
      let translation = gestureRecognizer.translation(in: self)
      var newMaxX = min(rightEdgeView.frame.maxX + translation.x, bounds.width)
      newMaxX = max(newMaxX, leftEdgeView.frame.maxX + Constants.handleWidth)
      rightEdgeViewMaxX = newMaxX
      updateSubviewFrames()
      gestureRecognizer.setTranslation(.zero, in: self)
    default:
      break
    }
  }
  
  @objc private func dragCenter(_ gestureRecognizer: UIPanGestureRecognizer) {
    if gestureRecognizer.state == .began {
      centerDraggingViewWidth = centerDraggingView.frame.width
    }
    switch gestureRecognizer.state {
    case .began, .changed:
      var translationX = gestureRecognizer.translation(in: self).x
      var newOriginX = leftEdgeView.frame.origin.x + translationX
      if newOriginX < 0 {
        translationX -= newOriginX
        newOriginX = 0
      }
      var newMaxX = rightEdgeView.frame.maxX + translationX
      if newMaxX > bounds.width {
        translationX -= newMaxX - bounds.width
        newOriginX = leftEdgeView.frame.origin.x + translationX
        newMaxX = bounds.width
      }
      ignoreValueChange = true
      leftEdgeViewOriginX = newOriginX
      rightEdgeViewMaxX = newMaxX
      ignoreValueChange = false
      onBothValueChanged?(leftHandleValue, rightHandleValue)
      updateSubviewFrames()
      gestureRecognizer.setTranslation(.zero, in: self)
    default:
      break
    }
  }
}
