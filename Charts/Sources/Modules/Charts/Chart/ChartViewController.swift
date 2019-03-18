//
//  ChartViewController.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
  private let contentView = UIView()
  private let scrollView = UIScrollView()
  private let chartNameLabel = UILabel()
  private let chartNameLabelContainer = UIView()
  private let chartMiniatureView = ChartMiniatureView()
  private let chartsBackgroundView = UIView()
  private let chartView = ChartView()
  private let chartElemetsToggleView = ChartElementsToggleView()
  private let chart: Chart
  private var chartUpdateWorkItem: DispatchWorkItem?
  private var switchDisplayModesButton = UIButton(type: .system)
  
  init(chart: Chart, chartName: String) {
    self.chart = chart
    chartNameLabel.text = chartName.uppercased()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    configure()
    bindChart()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    chartMiniatureView.layoutIfNeeded()
    chartMiniatureView.leftHandleValue = 0.7
    chartMiniatureView.rightHandleValue = 1
    chart.xAxis.updateBothSegmentationLimits(leftLimit: chartMiniatureView.leftHandleValue,
                                             rightLimit: chartMiniatureView.rightHandleValue)
  }
  
  private func setup() {
    view.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    setupScrollView()
    setupChartNameLabel()
    setupChartsBackgroundView()
    setupChartView()
    setupChartMiniatureView()
    setupChartElemetsToggleView()
    setupSwitchDisplayModesButton()
  }
  
  private func configure() {
    chartElemetsToggleView.configure(yAxes: chart.yAxes)
    chartView.configure(chart: chart)
  }
  
  private func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isDirectionalLockEnabled = true
    
    scrollView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
  }
  
  private func setupChartNameLabel() {
    contentView.addSubview(chartNameLabelContainer)
    chartNameLabelContainer.translatesAutoresizingMaskIntoConstraints = false
    chartNameLabelContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    chartNameLabelContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    chartNameLabelContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    chartNameLabelContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    chartNameLabelContainer.addSubview(chartNameLabel)
    chartNameLabel.translatesAutoresizingMaskIntoConstraints = false
    chartNameLabel.leadingAnchor.constraint(equalTo: chartNameLabelContainer.leadingAnchor, constant: 16).isActive = true
    chartNameLabel.topAnchor.constraint(equalTo: chartNameLabelContainer.topAnchor, constant: 25).isActive = true
    chartNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
    chartNameLabel.textColor = .darkGray
  }
  
  private func setupChartsBackgroundView() {
    contentView.addSubview(chartsBackgroundView)
    chartsBackgroundView.backgroundColor = .white
    chartsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    chartsBackgroundView.topAnchor.constraint(equalTo: chartNameLabelContainer.bottomAnchor).isActive = true
    chartsBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    chartsBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    
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
  
  private func setupSwitchDisplayModesButton() {
    let buttonContainerView = UIView()
    buttonContainerView.backgroundColor = .white
    contentView.addSubview(buttonContainerView)
    buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
    buttonContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    buttonContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    buttonContainerView.topAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor, constant: 35).isActive = true
    buttonContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -35).isActive = true
    buttonContainerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    let topSeparatorView = UIView()
    topSeparatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    buttonContainerView.addSubview(topSeparatorView)
    topSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    topSeparatorView.topAnchor.constraint(equalTo: buttonContainerView.topAnchor).isActive = true
    topSeparatorView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor).isActive = true
    topSeparatorView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor).isActive = true
    topSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    let bottomSeparatorView = UIView()
    bottomSeparatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    buttonContainerView.addSubview(bottomSeparatorView)
    bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    bottomSeparatorView.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor).isActive = true
    bottomSeparatorView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor).isActive = true
    bottomSeparatorView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor).isActive = true
    bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    buttonContainerView.addSubview(switchDisplayModesButton)
    switchDisplayModesButton.translatesAutoresizingMaskIntoConstraints = false
    switchDisplayModesButton.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor).isActive = true
    switchDisplayModesButton.bottomAnchor.constraint(equalTo: bottomSeparatorView.topAnchor).isActive = true
    switchDisplayModesButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor).isActive = true
    switchDisplayModesButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor).isActive = true
    switchDisplayModesButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    switchDisplayModesButton.setTitle("Switch to Night Mode", for: .normal)
    switchDisplayModesButton.addTarget(self, action: #selector(handleSwitchDisplayModesButtonTap(_:)), for: .touchUpInside)
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
  
  @objc private func handleSwitchDisplayModesButtonTap(_ sender: UIButton) {
    
  }
}

