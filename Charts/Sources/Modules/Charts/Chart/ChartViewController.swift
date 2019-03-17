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
  private let chartElemetsToggleView = ChartElementsToggleView()
  private let chart: Chart
  private var chartUpdateWorkItem: DispatchWorkItem?
  
  init(chart: Chart) {
    self.chart = chart
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bindChart()
  }
  
  private func setup() {
    view.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    setupChartsBackgroundView()
    setupChartView()
    setupChartMiniatureView()
    setupChartElemetsToggleView()
    chartElemetsToggleView.configure(yAxes: chart.yAxes)
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
      guard let self = self else { return }
      self.chartView.configure(chart: self.chart)
    }
  }
  
  private func setupChartMiniatureView() {
    chartsBackgroundView.addSubview(chartMiniatureView)
    chartMiniatureView.translatesAutoresizingMaskIntoConstraints = false
    chartMiniatureView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor, constant: 16).isActive = true
    chartMiniatureView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor, constant: -16).isActive = true
    chartMiniatureView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 12).isActive = true
    chartMiniatureView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    chartMiniatureView.onNeedsReconfiguring = { [weak self] in
      guard let self = self else { return }
      self.chartMiniatureView.configure(chart: self.chart)
    }
    chartMiniatureView.onLeftHandleValueChanged = { [weak self] value in
      guard let self = self else { return }
      self.chart.xAxis.leftSegmentationLimit = value
    }
    chartMiniatureView.onRightHandleValueChanged = { [weak self] value in
      guard let self = self, value > 0 else { return }
      self.chart.xAxis.rightSegmentationLimit = value
    }
    chartMiniatureView.onBothValueChanged = { [weak self] leftValue, rightValue in
      guard let self = self else { return }
      self.chart.xAxis.updateBothSegmentationLimits(leftLimit: leftValue, rightLimit: rightValue)
    }
  }
  
  private func setupChartElemetsToggleView() {
    chartsBackgroundView.addSubview(chartElemetsToggleView)
    chartElemetsToggleView.translatesAutoresizingMaskIntoConstraints = false
    chartElemetsToggleView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor).isActive = true
    chartElemetsToggleView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor).isActive = true
    chartElemetsToggleView.topAnchor.constraint(equalTo: chartMiniatureView.bottomAnchor, constant: 16).isActive = true
    chartElemetsToggleView.bottomAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor).isActive = true
    chartElemetsToggleView.onToggledYAxis = { [weak self] _ in
      self?.handleYAxisToggled()
    }
  }
  
  private func bindChart() {
    chart.onSegmentationUpdated = { [weak self] in
      guard let self = self else { return }
      self.chartUpdateWorkItem?.cancel()
      let work = DispatchWorkItem { [weak self] in
        guard let self = self else { return }
        self.chartView.configure(chart: self.chart)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.001, execute: work)
      self.chartUpdateWorkItem = work
    }
    chart.onSegmentationNormalizedUpdated = { [weak self] in
      guard let self = self else { return }
      self.chartView.animate(to: self.chart)
    }
  }
  
  private func handleYAxisToggled() {
    chart.updateSegmentation(shouldWait: false)
    chartMiniatureView.animate(to: chart)
  }
}

