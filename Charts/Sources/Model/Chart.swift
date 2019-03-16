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
  var xAxis: XAxis
  private var normalizationWorkItem: DispatchWorkItem?
  
  var onSegmentationUpdated: (() -> Void)?
  var onSegmentationNormalizedUpdated: (() -> Void)?
  
  init(xAxis: XAxis, yAxes: [YAxis]) {
    self.xAxis = xAxis
    self.yAxes = yAxes
    
    xAxis.onSegmentationChanged = { [unowned self] in
      var maxValue: Int = 0
      var minValue: Int = Int.max
      var valuesArray: [[Int]] = []
      let leftIndex = self.xAxis.leftSegmentationIndex
      let rightIndex = self.xAxis.rightSegmentationIndex
      for yAxis in self.yAxes {
        let segmentedUnnormalizedValues = yAxis.segmentedUnnormalizedValues(leftSegmentationIndex: leftIndex,
                                                                            rightSegmentationIndex: rightIndex)
        let newMax = segmentedUnnormalizedValues.max() ?? 0
        if newMax > maxValue {
          maxValue = newMax
        }
        let newMin = segmentedUnnormalizedValues.min() ?? 0
        if newMin < minValue {
          minValue = newMin
        }
        valuesArray.append(segmentedUnnormalizedValues)
      }
      
      self.onSegmentationUpdated?()
      
      self.normalizationWorkItem?.cancel()
      let work = DispatchWorkItem { [weak self, minValue, maxValue, valuesArray] in
        guard let self = self else { return }
        for (index, yAxis) in self.yAxes.enumerated() {
          yAxis.updateSegmentation(unnormalizedValues: valuesArray[index], minValue: minValue, maxValue: maxValue)
        }
        self.onSegmentationNormalizedUpdated?()
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: work)
      self.normalizationWorkItem = work
    }
  }
}
