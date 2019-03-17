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

class DraggableView: UIView {
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
  
  private var centerDraggingViewWidth: CGFloat = 0
  private var leftEdgeViewOriginX: CGFloat = 0 {
    didSet {
      onLeftHandleValueChanged?(leftHandleValue)
    }
  }
  private var rightEdgeViewMaxX: CGFloat = 0 {
    didSet {
      onRightHandleValueChanged?(rightHandleValue)
    }
  }
  private var updatedSubviewsForBounds: CGRect = .zero
  
  var leftHandleValue: Double {
    return Double(leftEdgeView.frame.minX / bounds.width)
  }
  
  var rightHandleValue: Double {
    return Double(rightEdgeView.frame.maxX / bounds.width)
  }
  
  var onLeftHandleValueChanged: ((Double) -> Void)?
  var onRightHandleValueChanged: ((Double) -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
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
    
    let backgroundColor = UIColor(red: 202 / 255, green: 212 / 255, blue: 222 / 255, alpha: 0.9)
    let overlayColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 0.6)
    leftEdgeView.backgroundColor = backgroundColor
    rightEdgeView.backgroundColor = backgroundColor
    topSeparator.backgroundColor = backgroundColor
    bottomSeparator.backgroundColor = backgroundColor
    leftDimmingView.backgroundColor = overlayColor
    rightDimmingView.backgroundColor = overlayColor
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
    leftEdgeDraggingView.frame.size = CGSize(width: leftEdgeView.frame.width * 3, height: leftEdgeView.frame.height)
    leftEdgeDraggingView.center = leftEdgeView.center
    rightEdgeDraggingView.frame.size = leftEdgeDraggingView.frame.size
    rightEdgeDraggingView.center = rightEdgeView.center
    let centerWidth = rightEdgeView.frame.origin.x - leftEdgeView.frame.maxX - 2 * Constants.handleWidth
    centerDraggingView.frame = CGRect(x: leftEdgeView.frame.maxX + Constants.handleWidth, y: 0,
                                      width: centerWidth, height: bounds.size.height)
    leftDimmingView.frame = CGRect(x: 0, y: 1,
                                   width: leftEdgeView.frame.minX + Constants.handleWidth,
                                   height: bounds.size.height - 2)
    rightDimmingView.frame = CGRect(x: rightEdgeView.frame.maxX - Constants.handleWidth, y: 1,
                                    width: bounds.size.width - rightEdgeView.frame.maxX + Constants.handleWidth,
                                    height: bounds.size.height - 2)
  }
  
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
      leftEdgeViewOriginX = newOriginX
      rightEdgeViewMaxX = newMaxX
      updateSubviewFrames()
      gestureRecognizer.setTranslation(.zero, in: self)
    default:
      break
    }
  }
}
