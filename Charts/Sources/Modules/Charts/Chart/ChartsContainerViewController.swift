//
//  ChartsContainerViewController.swift
//  Charts
//
//  Created by Daria Novodon on 08/09/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

protocol ChartsContainerViewControllerDelegate: class {
  func chartViewControllerDidToggleDayNightMode(_ viewController: ChartsContainerViewController)
}

class ChartsContainerViewController: UIViewController, DayNightViewConfigurable {

  // MARK: - UI elements
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let stackView = UIStackView()
  private let buttonContainerView = UIView()
  private let buttonTopSeparatorView = UIView()
  private let buttonBottomSeparatorView = UIView()
  private let switchDisplayModesButton = UIButton(type: .system)

  // MARK: - Properties
  private let dayNightModeToggler: DayNightModeToggler
  private var chartViewControllers: [ChartViewController] = []

  weak var delegate: ChartsContainerViewControllerDelegate?

  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return [.left, .right]
  }

  // MARK: - Init

  init(charts: [Chart], dayNightModeToggler: DayNightModeToggler) {
    self.dayNightModeToggler = dayNightModeToggler
    chartViewControllers = charts.map { ChartViewController(chart: $0, dayNightModeToggler: dayNightModeToggler) }
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
    setup()
    configure(dayNightModeToggler: dayNightModeToggler)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
  }

  // MARK: - Public methods

  func configure(dayNightModeToggler: DayNightModeToggler) {
    view.backgroundColor = dayNightModeToggler.darkBackgroundColor
    buttonTopSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    buttonBottomSeparatorView.backgroundColor = dayNightModeToggler.separatorColor
    buttonContainerView.backgroundColor = dayNightModeToggler.lightBackgroundColor
    let title = dayNightModeToggler.currentMode == .day ? "Switch to Night Mode"
      : "Switch to Day Mode"
    switchDisplayModesButton.setTitle(title, for: .normal)
    chartViewControllers.forEach { $0.configure(dayNightModeToggler: dayNightModeToggler) }
    setNeedsStatusBarAppearanceUpdate()
  }

  // MARK: - Actions

  @objc private func handleSwitchDisplayModesButtonTap(_ sender: UIButton) {
    dayNightModeToggler.toggle()
    configure(dayNightModeToggler: dayNightModeToggler)
    delegate?.chartViewControllerDidToggleDayNightMode(self)
  }
}

// MARK: - Setup UI

extension ChartsContainerViewController {
  private func setup() {
    view.backgroundColor = dayNightModeToggler.darkBackgroundColor
    setupScrollView()
    setupContentView()
    setupStackView()
    setupChartViewControllers()
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
  }

  private func setupContentView() {
    scrollView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
  }

  private func setupStackView() {
    contentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 0
  }

  private func setupChartViewControllers() {
    for viewControlloller in chartViewControllers {
      let containerView = UIView()
      stackView.addArrangedSubview(containerView)
      add(viewController: viewControlloller, to: containerView)
    }
  }

  private func setupSwitchDisplayModesButton() {
    contentView.addSubview(buttonContainerView)
    buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
    buttonContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    buttonContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    buttonContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 35).isActive = true
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
}
