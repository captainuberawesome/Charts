//
//  ChartViewController.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
  private let chartMiniatureView = ChartMiniatureView()
  private let chartView = ChartView()
  private var chart: Chart?
  private var chartUpdateWorkItem: DispatchWorkItem?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindChart()
  }
  
  private func setup() {
    setupChartMiniatureView()
    setupChartView()
  }

  private func setupChartMiniatureView() {
    view.addSubview(chartMiniatureView)
    chartMiniatureView.translatesAutoresizingMaskIntoConstraints = false
    chartMiniatureView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    chartMiniatureView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    chartMiniatureView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    chartMiniatureView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    chartMiniatureView.onNeedsReconfiguring = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartMiniatureView.configure(chart: chart)
    }
    chartMiniatureView.onLeftHandleValueChanged = { [weak self] value in
      guard let self = self, let chart = self.chart else { return }
      chart.xAxis.leftSegmentationLimit = value
    }
    chartMiniatureView.onRightHandleValueChanged = { [weak self] value in
      guard let self = self, let chart = self.chart, value > 0 else { return }
      chart.xAxis.rightSegmentationLimit = value
    }
  }
  
  private func setupChartView() {
    view.addSubview(chartView)
    chartView.translatesAutoresizingMaskIntoConstraints = false
    chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    chartView.bottomAnchor.constraint(equalTo: chartMiniatureView.topAnchor, constant: -20).isActive = true
    chartView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    
    chartView.onNeedsReconfiguring = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartView.configure(chart: chart)
    }
  }
  
  private func bindChart() {
    chart = DataImporter.importData().first
    chart?.onSegmentationUpdated = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartUpdateWorkItem?.cancel()
      let work = DispatchWorkItem { [weak self] in
        self?.chartView.configure(chart: chart)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.001, execute: work)
      self.chartUpdateWorkItem = work
    }
    chart?.onSegmentationNormalizedUpdated = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartView.animate(to: chart)
    }
  }
}

