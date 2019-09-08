//
//  ChartViewController.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController, DayNightViewConfigurable {
  
  // MARK: - UI elements

  private let titleContainer = UIView()
  private let titleLabel = UILabel()
  private let chartMiniatureViewContainer = ViewWithTouchesOutside()
  private var chartMiniatureView = ChartMiniatureView()
  private let chartsBackgroundView = UIView()
  private let chartViewContainer = UIView()
  private var chartView: ChartView
  private let chartsTopSeparatorView = UIView()
  private let chartsBottomSeparatorView = UIView()
  private let chartElemetsToggleView = ChartElementsToggleView()
  
  // MARK: - Properties

  private let dayNightModeToggler: DayNightModeToggler
  private var configuredChartMiniatureViewPosition = false
  private var chart: Chart

  // MARK: - Init
  
  init(chart: Chart, dayNightModeToggler: DayNightModeToggler) {
    self.chart = chart
    self.dayNightModeToggler = dayNightModeToggler
    chartView = ChartView(dayNightModeToggler: dayNightModeToggler)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    configure()
    bindChart()
    configure(dayNightModeToggler: dayNightModeToggler)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    chartView.setNeedsLayout()
    chartView.layoutIfNeeded()
    if !configuredChartMiniatureViewPosition {
      configureChartMiniatureViewPosition()
      configuredChartMiniatureViewPosition = true
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    chartView.animationsAllowed = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    chartView.animationsAllowed = false
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    chartView.stopAnimation()
    chartMiniatureView.stopAnimation()
  }
  
  // MARK: - Public methods
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    chartsBackgroundView.backgroundColor = dayNightModeToggler.lightBackgroundColor
    titleContainer.backgroundColor = dayNightModeToggler.darkBackgroundColor
    chartsTopSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    chartsBottomSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    titleLabel.textColor = dayNightModeToggler.dullerTextColor
    chartView.configure(dayNightModeToggler: dayNightModeToggler)
    chartMiniatureView.configure(dayNightModeToggler: dayNightModeToggler)
    chartElemetsToggleView.configure(dayNightModeToggler: dayNightModeToggler)
  }
  
  // MARK: - Configure chart
  
  private func configure() {
    chartElemetsToggleView.configure(yAxes: chart.yAxes)
    chartView.configure(chart: chart)
  }
  
  // MARK: - Bind chart callbacks
  
  private func bindChart() {
    chart.onSegmentationUpdated = { [weak self] in
      guard let self = self else { return }
      self.chartView.configure(chart: self.chart)
    }
    chart.onSegmentationNormalizedUpdated = { [weak self] in
      guard let self = self else { return }
      self.chartView.animate(to: self.chart)
    }
    chart.onNeedsXAxisUpdate = { [weak self] in
      guard let self = self else { return }
      self.chartView.configureXAxis(chart: self.chart)
    }
  }
  
  // MARK: - Private methods
  
  private func handleYAxisToggled() {
    chart.updateSegmentation(shouldWait: false)
    chartMiniatureView.animate(to: chart)
  }
  
  private func configureChartMiniatureViewPosition() {
    chartMiniatureView.layoutIfNeeded()
    chartMiniatureView.leftHandleValue = 0.6
    chartMiniatureView.rightHandleValue = 1
    chart.xAxis.updateBothSegmentationLimits(leftLimit: chartMiniatureView.leftHandleValue,
                                             rightLimit: chartMiniatureView.rightHandleValue)
    chart.updateSegmentation(shouldWait: false)
    chartView.adjustXAxisValuesAlpha()
  }
}

// MARK: - Setup UI

extension ChartViewController {
  private func setup() {
    view.backgroundColor = .clear
    setupTitleContainer()
    setupChartsBackgroundView()
    setupChartViewContainer()
    setupChartView()
    setupChartMiniatureContainerView()
    setupChartMiniatureView()
    setupChartElemetsToggleView()
  }

  private func setupTitleContainer() {
    view.addSubview(titleContainer)
    titleContainer.translatesAutoresizingMaskIntoConstraints = false
    titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    titleContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    titleContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true

    titleContainer.addSubview(titleLabel)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -8).isActive = true
    titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
    titleLabel.text = chart.name
    titleLabel.textAlignment = .left
  }
  
  private func setupChartsBackgroundView() {
    view.addSubview(chartsBackgroundView)
    chartsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    chartsBackgroundView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor).isActive = true
    chartsBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    chartsBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    chartsBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    chartsBackgroundView.addSubview(chartsTopSeparatorView)
    chartsTopSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    chartsTopSeparatorView.topAnchor.constraint(equalTo: chartsBackgroundView.topAnchor).isActive = true
    chartsTopSeparatorView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor).isActive = true
    chartsTopSeparatorView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor).isActive = true
    chartsTopSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    chartsBackgroundView.addSubview(chartsBottomSeparatorView)
    chartsBottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    chartsBottomSeparatorView.bottomAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor).isActive = true
    chartsBottomSeparatorView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor).isActive = true
    chartsBottomSeparatorView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor).isActive = true
    chartsBottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
  }
  
  private func setupChartViewContainer() {
    chartsBackgroundView.addSubview(chartViewContainer)
    chartViewContainer.translatesAutoresizingMaskIntoConstraints = false
    chartViewContainer.topAnchor.constraint(equalTo: chartsBackgroundView.topAnchor).isActive = true
    chartViewContainer.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor, constant: 16).isActive = true
    chartViewContainer.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor, constant: -16).isActive = true
    chartViewContainer.heightAnchor.constraint(equalToConstant: 310).isActive = true
  }
  
  private func setupChartView() {
    chartViewContainer.addSubview(chartView)
    chartView.translatesAutoresizingMaskIntoConstraints = false
    chartView.leadingAnchor.constraint(equalTo: chartViewContainer.leadingAnchor).isActive = true
    chartView.trailingAnchor.constraint(equalTo: chartViewContainer.trailingAnchor).isActive = true
    chartView.topAnchor.constraint(equalTo: chartViewContainer.topAnchor).isActive = true
    chartView.bottomAnchor.constraint(equalTo: chartViewContainer.bottomAnchor).isActive = true
    
    chartView.onNeedsReconfiguring = { [weak self, unowned chartView] in
      guard let self = self else { return }
      chartView.configure(chart: self.chart)
    }
    chartView.onChartTapped = { [weak self, unowned chartView] location in
      guard let self = self else { return }
      chartView.addSelectionBubble(location: location, chart: self.chart)
    }
  }
  
  private func setupChartMiniatureContainerView() {
    chartsBackgroundView.addSubview(chartMiniatureViewContainer)
    chartMiniatureViewContainer.translatesAutoresizingMaskIntoConstraints = false
    chartMiniatureViewContainer.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor,
                                                         constant: 16).isActive = true
    chartMiniatureViewContainer.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor,
                                                          constant: -16).isActive = true
    chartMiniatureViewContainer.topAnchor.constraint(equalTo: chartViewContainer.bottomAnchor, constant: 12).isActive = true
    chartMiniatureViewContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
  }
  
  private func setupChartMiniatureView() {
    chartMiniatureViewContainer.addSubview(chartMiniatureView)
    chartMiniatureView.translatesAutoresizingMaskIntoConstraints = false
    chartMiniatureView.leadingAnchor.constraint(equalTo: chartMiniatureViewContainer.leadingAnchor).isActive = true
    chartMiniatureView.trailingAnchor.constraint(equalTo: chartMiniatureViewContainer.trailingAnchor).isActive = true
    chartMiniatureView.topAnchor.constraint(equalTo: chartMiniatureViewContainer.topAnchor).isActive = true
    chartMiniatureView.bottomAnchor.constraint(equalTo: chartMiniatureViewContainer.bottomAnchor).isActive = true
    
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
    chartElemetsToggleView.topAnchor.constraint(equalTo: chartMiniatureViewContainer.bottomAnchor, constant: 8).isActive = true
    chartElemetsToggleView.bottomAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor).isActive = true
    chartElemetsToggleView.onToggledYAxis = { [weak self] _ in
      self?.handleYAxisToggled()
    }
  }
}
