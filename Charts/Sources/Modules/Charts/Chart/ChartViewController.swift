//
//  ChartViewController.swift
//  Charts
//
//  Created by Daria Novodon on 14/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

protocol ChartViewControllerDelegate: class {
  func chartViewControllerDidToggleDayNightMode(_ viewController: ChartViewController)
}

class ChartViewController: UIViewController, DayNightViewConfigurable {
  
  // MARK: - Properties
  
  private let contentView = UIView()
  private let scrollView = UIScrollView()
  private let chartNameLabel = UILabel()
  private let chartNameLabelContainer = UIView()
  private let chartMiniatureView = ChartMiniatureView()
  private let chartsBackgroundView = UIView()
  private let buttonContainerView = UIView()
  private let chartView: ChartView
  private let chartsTopSeparatorView = UIView()
  private let chartsBottomSeparatorView = UIView()
  private let buttonTopSeparatorView = UIView()
  private let buttonBottomSeparatorView = UIView()
  private let chartElemetsToggleView = ChartElementsToggleView()
  private var chartUpdateWorkItem: DispatchWorkItem?
  private let switchDisplayModesButton = UIButton(type: .system)
  private let chart: Chart
  private let dayNightModeToggler: DayNightModeToggler
  private var configuredChartMiniatureViewPosition = false
  
  weak var delegate: ChartViewControllerDelegate?
  
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return [.left, .right]
  }
  
  // MARK: - Init
  
  init(chart: Chart, chartName: String, dayNightModeToggler: DayNightModeToggler) {
    self.chart = chart
    self.dayNightModeToggler = dayNightModeToggler
    chartNameLabel.text = chartName.uppercased()
    chartView = ChartView(dayNightModeToggler: dayNightModeToggler)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Overrides
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    switch dayNightModeToggler.currentMode {
    case .day:
      return .default
    case .night:
      return .lightContent
    }
  }
  
  // MARK: - View life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setDefaultBackButtonTitle()
    setup()
    configure()
    bindChart()
    configure(dayNightModeToggler: dayNightModeToggler)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !configuredChartMiniatureViewPosition {
      chartMiniatureView.layoutIfNeeded()
      chartMiniatureView.leftHandleValue = 0.7
      chartMiniatureView.rightHandleValue = 1
      chart.xAxis.updateBothSegmentationLimits(leftLimit: chartMiniatureView.leftHandleValue,
                                               rightLimit: chartMiniatureView.rightHandleValue)
      configuredChartMiniatureViewPosition = true
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    chartView.animationsAllowed = true
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    chartView.animationsAllowed = false
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    chartView.stopAnimation()
    chartMiniatureView.stopAnimation()
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }
  
  // MARK: - Public methods
  
  func configure(dayNightModeToggler: DayNightModeToggler) {
    view.backgroundColor = dayNightModeToggler.darkBackgroundColor
    chartNameLabel.textColor = dayNightModeToggler.dullestTextColor
    chartsBackgroundView.backgroundColor = dayNightModeToggler.lightBackgroundColor
    chartsTopSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    chartsBottomSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    buttonTopSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    buttonBottomSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    buttonContainerView.backgroundColor = dayNightModeToggler.lightBackgroundColor
    let title = dayNightModeToggler.currentMode == .day ? "Switch to Night Mode"
                                                        : "Switch to Day Mode"
    switchDisplayModesButton.setTitle(title, for: .normal)
    
    chartView.configure(dayNightModeToggler: dayNightModeToggler)
    chartMiniatureView.configure(dayNightModeToggler: dayNightModeToggler)
    chartElemetsToggleView.configure(dayNightModeToggler: dayNightModeToggler)
    setNeedsStatusBarAppearanceUpdate()
  }
  
  // MARK: - Setup
  
  private func setup() {
    setupScrollView()
    setupChartNameLabel()
    setupChartsBackgroundView()
    setupChartView()
    setupChartMiniatureView()
    setupChartElemetsToggleView()
    setupSwitchDisplayModesButton()
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
    chartNameLabel.topAnchor.constraint(equalTo: chartNameLabelContainer.topAnchor, constant: 30).isActive = true
    chartNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
  }
  
  private func setupChartsBackgroundView() {
    contentView.addSubview(chartsBackgroundView)
    chartsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    chartsBackgroundView.topAnchor.constraint(equalTo: chartNameLabelContainer.bottomAnchor).isActive = true
    chartsBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    chartsBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
  
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
  
  private func setupChartView() {
    chartsBackgroundView.addSubview(chartView)
    chartView.translatesAutoresizingMaskIntoConstraints = false
    chartView.topAnchor.constraint(equalTo: chartsBackgroundView.topAnchor).isActive = true
    chartView.leadingAnchor.constraint(equalTo: chartsBackgroundView.leadingAnchor, constant: 16).isActive = true
    chartView.trailingAnchor.constraint(equalTo: chartsBackgroundView.trailingAnchor, constant: -16).isActive = true
    chartView.heightAnchor.constraint(equalToConstant: 310).isActive = true
    
    chartView.onNeedsReconfiguring = { [weak self, unowned chartView] in
      guard let self = self else { return }
      chartView.configure(chart: self.chart)
    }
    chartView.onChartTapped = { [weak self, unowned chartView] location in
      guard let self = self else { return }
      chartView.addSelectionBubble(location: location, chart: self.chart)
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
    chartElemetsToggleView.topAnchor.constraint(equalTo: chartMiniatureView.bottomAnchor, constant: 8).isActive = true
    chartElemetsToggleView.bottomAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor).isActive = true
    chartElemetsToggleView.onToggledYAxis = { [weak self] _ in
      self?.handleYAxisToggled()
    }
  }
  
  private func setupSwitchDisplayModesButton() {
    contentView.addSubview(buttonContainerView)
    buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
    buttonContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    buttonContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    buttonContainerView.topAnchor.constraint(equalTo: chartsBackgroundView.bottomAnchor, constant: 35).isActive = true
    buttonContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -35).isActive = true
    buttonContainerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    buttonContainerView.addSubview(buttonTopSeparatorView)
    buttonTopSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    buttonTopSeparatorView.topAnchor.constraint(equalTo: buttonContainerView.topAnchor).isActive = true
    buttonTopSeparatorView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor).isActive = true
    buttonTopSeparatorView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor).isActive = true
    buttonTopSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    buttonContainerView.addSubview(buttonBottomSeparatorView)
    buttonBottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
    buttonBottomSeparatorView.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor).isActive = true
    buttonBottomSeparatorView.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor).isActive = true
    buttonBottomSeparatorView.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor).isActive = true
    buttonBottomSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    buttonContainerView.addSubview(switchDisplayModesButton)
    switchDisplayModesButton.translatesAutoresizingMaskIntoConstraints = false
    switchDisplayModesButton.topAnchor.constraint(equalTo: buttonTopSeparatorView.bottomAnchor).isActive = true
    switchDisplayModesButton.bottomAnchor.constraint(equalTo: buttonBottomSeparatorView.topAnchor).isActive = true
    switchDisplayModesButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor).isActive = true
    switchDisplayModesButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor).isActive = true
    switchDisplayModesButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    switchDisplayModesButton.addTarget(self, action: #selector(handleSwitchDisplayModesButtonTap(_:)), for: .touchUpInside)
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
  
  // MARK: - Private methods
  
  private func handleYAxisToggled() {
    chart.updateSegmentation(shouldWait: false)
    chartMiniatureView.animate(to: chart)
  }
  
  // MARK: - Actions
  
  @objc private func handleSwitchDisplayModesButtonTap(_ sender: UIButton) {
    dayNightModeToggler.toggle()
    configure(dayNightModeToggler: dayNightModeToggler)
    delegate?.chartViewControllerDidToggleDayNightMode(self)
  }
}
