//
//  Chart.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import Foundation

class Chart {
  var yAxes: [YAxis]
  var toggledYAxes: [YAxis] {
    return yAxes.filter { $0.isEnabled }
  }
  var xAxis: XAxis
  private var normalizationWorkItem: DispatchWorkItem?
  
  var onSegmentationUpdated: (() -> Void)?
  var onSegmentationNormalizedUpdated: (() -> Void)?
  
  init(xAxis: XAxis, yAxes: [YAxis]) {
    self.xAxis = xAxis
    self.yAxes = yAxes
    
    xAxis.onSegmentationChanged = { [unowned self] in
      self.updateSegmentation()
    }
  }
  
  func updateSegmentation(shouldWait: Bool = true) {
    self.normalizationWorkItem?.cancel()
    
    var maxValue: Int = 0
    var minValue: Int = Int.max
    var valuesArray: [[Int]] = []
    let leftIndex = xAxis.leftSegmentationIndex
    let rightIndex = xAxis.rightSegmentationIndex
    for yAxis in yAxes {
      let segmentedUnnormalizedValues = yAxis.segmentedUnnormalizedValues(leftSegmentationIndex: leftIndex,
                                                                          rightSegmentationIndex: rightIndex)
      
      if yAxis.isEnabled {
        let newMax = segmentedUnnormalizedValues.max() ?? 0
        if newMax > maxValue {
          maxValue = newMax
        }
        let newMin = segmentedUnnormalizedValues.min() ?? 0
        if newMin < minValue {
          minValue = newMin
        }
      }
      
      valuesArray.append(segmentedUnnormalizedValues)
    }
    
    if shouldWait {
      onSegmentationUpdated?()
    }
    
    let work = DispatchWorkItem { [weak self, minValue, maxValue, valuesArray] in
      guard let self = self else { return }
      for (index, yAxis) in self.yAxes.enumerated() {
        yAxis.updateSegmentation(unnormalizedValues: valuesArray[index], minValue: minValue, maxValue: maxValue)
      }
      self.onSegmentationNormalizedUpdated?()
    }
    if shouldWait {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: work)
      normalizationWorkItem = work
    } else {
      DispatchQueue.main.async(execute: work)
    }
  }
}
