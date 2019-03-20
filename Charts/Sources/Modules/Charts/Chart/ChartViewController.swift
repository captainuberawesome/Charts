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
  
  // MARK: - UI elements
  
  private let segmentedControl = UISegmentedControl()
  private let contentView = UIView()
  private let scrollView = UIScrollView()
  private let segmentedControlContainer = UIView()
  private let chartMiniatureViewContainer = UIView()
  private var chartMiniatureView = ChartMiniatureView()
  private let chartsBackgroundView = UIView()
  private let buttonContainerView = UIView()
  private let chartViewContainer = UIView()
  private var chartView: ChartView
  private let chartsTopSeparatorView = UIView()
  private let chartsBottomSeparatorView = UIView()
  private let buttonTopSeparatorView = UIView()
  private let buttonBottomSeparatorView = UIView()
  private let chartElemetsToggleView = ChartElementsToggleView()
  private var chartUpdateWorkItem: DispatchWorkItem?
  private let switchDisplayModesButton = UIButton(type: .system)
  
  // MARK: - Properties
  
  private let charts: [Chart]
  private let dayNightModeToggler: DayNightModeToggler
  private var configuredChartMiniatureViewPosition = false
  private var currentSelectedIndex: Int = 0
  private var chart: Chart?
  
  weak var delegate: ChartViewControllerDelegate?
  
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return [.left, .right]
  }
  
  // MARK: - Init
  
  init(charts: [Chart], dayNightModeToggler: DayNightModeToggler) {
    self.charts = charts
    self.dayNightModeToggler = dayNightModeToggler
    chartView = ChartView(dayNightModeToggler: dayNightModeToggler)
    super.init(nibName: nil, bundle: nil)
    if !charts.isEmpty {
      chart = Chart(chart: charts[0])
    }
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
      configureChartMiniatureViewPosition()
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
    setupChartViewContainer()
    setupChartView()
    setupChartMiniatureContainerView()
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
    contentView.addSubview(segmentedControlContainer)
    segmentedControlContainer.translatesAutoresizingMaskIntoConstraints = false
    segmentedControlContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    segmentedControlContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    segmentedControlContainer.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    segmentedControlContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    segmentedControlContainer.addSubview(segmentedControl)
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.centerXAnchor.constraint(equalTo: segmentedControlContainer.centerXAnchor).isActive = true
    segmentedControl.topAnchor.constraint(equalTo: segmentedControlContainer.topAnchor, constant: 10).isActive = true
    segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: segmentedControlContainer.leadingAnchor,
                                              constant: 8).isActive = true
    segmentedControl.trailingAnchor.constraint(lessThanOrEqualTo: segmentedControlContainer.trailingAnchor,
                                              constant: -8).isActive = true
    for index in 0..<charts.count {
      segmentedControl.insertSegment(withTitle: "Chart #\(index + 1)", at: index, animated: false)
    }
    segmentedControl.addTarget(self, action: #selector(handleSegmentSelected(_:)), for: .valueChanged)
    segmentedControl.selectedSegmentIndex = 0
  }
  
  private func setupChartsBackgroundView() {
    contentView.addSubview(chartsBackgroundView)
    chartsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    chartsBackgroundView.topAnchor.constraint(equalTo: segmentedControlContainer.bottomAnchor).isActive = true
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
      guard let self = self, let chart = self.chart else { return }
      chartView.configure(chart: chart)
    }
    chartView.onChartTapped = { [weak self, unowned chartView] location in
      guard let self = self, let chart = self.chart else { return }
      chartView.addSelectionBubble(location: location, chart: chart)
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
      guard let self = self, let chart = self.chart else { return }
      self.chartMiniatureView.configure(chart: chart)
    }
    chartMiniatureView.onLeftHandleValueChanged = { [weak self] value in
      guard let self = self, let chart = self.chart else { return }
      chart.xAxis.leftSegmentationLimit = value
    }
    chartMiniatureView.onRightHandleValueChanged = { [weak self] value in
      guard let self = self, value > 0, let chart = self.chart else { return }
      chart.xAxis.rightSegmentationLimit = value
    }
    chartMiniatureView.onBothValueChanged = { [weak self] leftValue, rightValue in
      guard let self = self, let chart = self.chart else { return }
      chart.xAxis.updateBothSegmentationLimits(leftLimit: leftValue, rightLimit: rightValue)
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
    guard let chart = chart else { return }
    chartElemetsToggleView.configure(yAxes: chart.yAxes)
    chartView.configure(chart: chart)
  }
  
  // MARK: - Bind chart callbacks
  
  private func bindChart() {
    chart?.onSegmentationUpdated = { [weak self] in
      guard let self = self else { return }
      self.chartUpdateWorkItem?.cancel()
      let work = DispatchWorkItem { [weak self] in
        guard let self = self, let chart = self.chart else { return }
        self.chartView.configure(chart: chart)
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.001, execute: work)
      self.chartUpdateWorkItem = work
    }
    chart?.onSegmentationNormalizedUpdated = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartView.animate(to: chart)
    }
    chart?.onNeedsXAxisUpdate = { [weak self] in
      guard let self = self, let chart = self.chart else { return }
      self.chartView.configureXAxis(chart: chart)
    }
  }
  
  // MARK: - Private methods
  
  private func handleYAxisToggled() {
    chart?.updateSegmentation(shouldWait: false)
    if let chart = chart {
      chartMiniatureView.animate(to: chart)
    }
  }
  
  private func reconfigureForChartChange() {
    chartView.removeFromSuperview()
    chartView = ChartView(dayNightModeToggler: dayNightModeToggler,
                          frame: CGRect(origin: .zero,
                                        size: CGSize(width: view.bounds.width - 32, height: 310)))
    chartView.animationsAllowed = false
    setupChartView()
    chartMiniatureView.removeFromSuperview()
    chartMiniatureView = ChartMiniatureView(frame: CGRect(origin: .zero,
                                                          size: CGSize(width: view.bounds.width - 32, height: 44)))
    setupChartMiniatureView()
    chartView.setNeedsLayout()
    chartView.layoutIfNeeded()
    chartMiniatureView.setNeedsLayout()
    chartMiniatureView.layoutIfNeeded()
    configure()
    bindChart()
    configureChartMiniatureViewPosition()
    chartView.animationsAllowed = true
    configure(dayNightModeToggler: dayNightModeToggler)
  }
  
  private func configureChartMiniatureViewPosition() {
    chartMiniatureView.layoutIfNeeded()
    chartMiniatureView.leftHandleValue = 0.7
    chartMiniatureView.rightHandleValue = 1
    chart?.xAxis.updateBothSegmentationLimits(leftLimit: chartMiniatureView.leftHandleValue,
                                              rightLimit: chartMiniatureView.rightHandleValue)
    chart?.updateSegmentation(shouldWait: false)
  }
  
  // MARK: - Actions
  
  @objc private func handleSegmentSelected(_ sender: UISegmentedControl) {
    guard segmentedControl.selectedSegmentIndex != currentSelectedIndex else { return }
    currentSelectedIndex = segmentedControl.selectedSegmentIndex
    chart = Chart(chart: charts[segmentedControl.selectedSegmentIndex])
    reconfigureForChartChange()
  }
  
  @objc private func handleSwitchDisplayModesButtonTap(_ sender: UIButton) {
    dayNightModeToggler.toggle()
    configure(dayNightModeToggler: dayNightModeToggler)
    delegate?.chartViewControllerDidToggleDayNightMode(self)
  }
}
