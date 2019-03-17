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
  private let chartsBackgroundView = UIView()
  private let chartView = ChartView()
  private var chart: Chart?
  private var chartUpdateWorkItem: DispatchWorkItem?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chart = DataImporter.importData().first
    setup()
    bindChart()
  }
  
  private func setup() {
    view.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    setupChartsBackgroundView()
    setupChartView()
    setupChartMiniatureView()
  }
  
  private func setupChartsBackgroundView() {
    view.addSubview(chartsBackgroundView)
    chartsBackgroundView.backgroundColor = .white
    chartsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    chartsBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
    chartsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    chartsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    let topSeparatorView = UIView()
    topSeparatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    chartsBackgroundView.addSubview(topSeparatorView)
    topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    topSeparatorView.topAnchor.constraint(equalTo: chartsBackgroundView.topAnchor).isActive = true
    topSeparatorView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor).isActive = true
    topSeparatorView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor).isActive = true
    topSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    let bottomSeparatorView = UIView()
    bottomSeparatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    chartsBackgroundView.addSubview(bottomSeparatorView)
    bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    bottomSeparatorView.bottomAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor).isActive = true
    bottomSeparatorView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor).isActive = true
    bottomSeparatorView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor).isActive = true
    bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
  }
  
  private func setupChartView() {
    chartsBackgroundView.addSubview(chartView)
    chartView.translatesAutoresizingMaskIntoConstraints = false
    chartView.topAnchor.constraint(equalTo: chartsBackgroundView.topAnchor).isActive = true
    chartView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor, constant: 16).isActive = true
    chartView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor, constant: -16).isActive = true
    chartView.heightAnchor.constraint(equalToConstant: 310).isActive = true
    
    chartView.onNeedsReconfiguring = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartView.configure(chart: chart)
    }
  }
  
  private func setupChartMiniatureView() {
    chartsBackgroundView.addSubview(chartMiniatureView)
    chartMiniatureView.translatesAutoresizingMaskIntoConstraints = false
    chartMiniatureView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor, constant: 16).isActive = true
    chartMiniatureView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor, constant: -16).isActive = true
    chartMiniatureView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 12).isActive = true
    chartMiniatureView.bottomAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor, constant: -10).isActive = true
    chartMiniatureView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
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
  
  private func bindChart() {
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

