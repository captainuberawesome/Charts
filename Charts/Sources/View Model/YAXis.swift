//
//  YAXis.swift
//  Charts
//
//  Created by Daria Novodon on 16/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

private struct Constants {
  static let numberOfSteps = 6
}

// MARK: - YValue

struct YValue {
  var percentageValue: Double
  var actualValue: Int
  var colorHex: String
}

// MARK: - YAxisSpan

struct YAxisSpan {
  let minY: Int
  let maxY: Int
  let step: Int
}

// MARK: - YAxis

class YAxis {
  // MARK: - Properties
  
  private let rawValues: [Int]
  private var maxValueAcrossY: Int
  private var minValueAcrossY: Int
  
  private (set) var allValues: [YValue]
  private (set) var allValuesNormalized: [YValue]
  private (set) var allValuesNormalizedToSegment: [YValue]
  private (set) var minValueAcrossYSegmented: Int
  private (set) var maxValueAcrossYSegmented: Int
  private (set) var step: YValue
  
  let colorHex: String
  let name: String
  
  var isEnabled = true
  
  // MARK: - Initializer
  
  init(values: [Int], colorHex: String, name: String, minValueAcrossY: Int, maxValueAcrossY: Int, step: Int) {
    self.colorHex = colorHex
    self.name = name
    self.maxValueAcrossY = maxValueAcrossY
    self.minValueAcrossY = minValueAcrossY
    self.step = YValue(percentageValue: Double(step) / Double(maxValueAcrossY - minValueAcrossY),
                       actualValue: step,
                       colorHex: colorHex)
    self.rawValues = values
    allValues = values.map {
      YValue(percentageValue: Double($0 - minValueAcrossY) / Double(maxValueAcrossY - minValueAcrossY),
             actualValue: $0, colorHex: colorHex)
    }
    allValuesNormalizedToSegment = allValues
    allValuesNormalized = allValues
    maxValueAcrossYSegmented = maxValueAcrossY
    minValueAcrossYSegmented = minValueAcrossY
  }
  
  // MARK: - Public methods
  
  func segmentedUnnormalizedValues(leftSegmentationIndex: Int, rightSegmentationIndex: Int) -> [Int] {
    let unnormalizedValues = rawValues.enumerated().filter {
      return $0.offset >= leftSegmentationIndex && $0.offset <= rightSegmentationIndex
    }.compactMap { $0.element } 
    return unnormalizedValues
  }
  
  func updateSegmentation(unnormalizedValues: [Int], minValue: Int, maxValue: Int) {
    let yAxisSpan = YAxis.calculateSpan(yMin: minValue, yMax: maxValue)
    maxValueAcrossYSegmented = yAxisSpan.maxY
    minValueAcrossYSegmented = yAxisSpan.minY
    self.step = YValue(percentageValue: Double(yAxisSpan.step) / Double(yAxisSpan.maxY - yAxisSpan.minY),
                       actualValue: yAxisSpan.step, colorHex: colorHex)
    allValuesNormalizedToSegment = rawValues.map {
      YValue(percentageValue: Double($0 - yAxisSpan.minY) / Double(yAxisSpan.maxY - yAxisSpan.minY), actualValue: $0,
             colorHex: colorHex)
    }
  }
  
  func updateNormalizedValues(minValue: Int, maxValue: Int) {
    allValuesNormalized = rawValues.map {
      YValue(percentageValue: Double($0 - minValue) / Double(maxValue - minValue), actualValue: $0, colorHex: colorHex)
    }
  }
  
  // MARK: - Public static methods
  
  static func calculateSpan(yMin: Int, yMax: Int) -> YAxisSpan {
    var step = calculateStep(yMin: yMin, yMax: yMax)
    
    var minValueAcrossY = Int(floor(Double(yMin)) / Double(step)) * step
    var maxValueAcrossY = Int(ceil(ceil(Double(yMax)) / Double(step))) * step
    
    if yMax == maxValueAcrossY {
      maxValueAcrossY += step
    }
    
    if yMin == minValueAcrossY {
      minValueAcrossY -= step
    }
    
    step = calculateStep(yMin: minValueAcrossY, yMax: maxValueAcrossY)
    
    minValueAcrossY = Int(floor(Double(yMin)) / Double(step)) * step
    maxValueAcrossY = Int(ceil(ceil(Double(yMax)) / Double(step))) * step
    
    if maxValueAcrossY == minValueAcrossY + step * (Constants.numberOfSteps - 1)
      || yMax == maxValueAcrossY {
      maxValueAcrossY += Int(ceil(0.75 * Double(step)))
    }
    
    return YAxisSpan(minY: minValueAcrossY, maxY: maxValueAcrossY, step: step)
  }
  
  static private func calculateStep(yMin: Int, yMax: Int) -> Int {
    let span = yMax - yMin
    var step = span / Constants.numberOfSteps
    
    if step == 0 {
      step = 5
    } else if step < 25 {
      step = Int(ceil(Double(step) / 5) * 5)
    } else if step < 100 {
      step = Int(ceil(Double(step) / 10) * 10)
    } else if step < 500 {
      step = Int(ceil(Double(step) / 50) * 50)
    } else if step < 1000 {
      step = Int(ceil(Double(step) / 100) * 100)
    } else if step < 5000 {
      step = Int(ceil(Double(step) / 500) * 500)
    } else {
      step = Int(ceil(Double(step) / 1000) * 1000)
    }
    
    return step
  }
}
