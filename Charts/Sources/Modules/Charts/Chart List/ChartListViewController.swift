//
//  ChartListViewController.swift
//  Charts
//
//  Created by Daria Novodon on 18/03/2019.
//  Copyright © 2019 dnovodon. All rights reserved.
//

import UIKit

protocol ChartListViewControllerDelegate: class {
  func chartListViewController(_ viewController: ChartListViewController, didSelectChart chart: Chart, title: String)
}

class ChartListViewController: UIViewController {
  // MARK: - Protperties
  private let tableView = UITableView(frame: .zero, style: .plain)
  private let charts: [Chart]
  
  weak var delegate: ChartListViewControllerDelegate?
  
  // MARK: - Init
  
  init(charts: [Chart]) {
    self.charts = charts
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setDefaultBackButtonTitle()
    setup()
  }
  
  // MARK: - Setup
  
  private func setup() {
    view.backgroundColor = UIColor(red: 239 / 255, green: 239 / 255, blue: 244 / 255, alpha: 1)
    setupTableView()
  }
  
  private func setupTableView() {
    view.addSubview(tableView)
    tableView.backgroundColor = .clear
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
    tableView.showsVerticalScrollIndicator = false
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.rowHeight = 44
    tableView.estimatedRowHeight = 44
    
    tableView.register(ChartTableViewCell.self, forCellReuseIdentifier: ChartTableViewCell.reuseIdentifier)
  }
}

// MARK: - UITableViewDataSource

extension ChartListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return charts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChartTableViewCell.reuseIdentifier,
                                                   for: indexPath) as? ChartTableViewCell else { return UITableViewCell () }
    cell.configure(title: "Chart #\(indexPath.row + 1)", showSeparator: indexPath.row + 1 == charts.count)
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView()
    footerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    footerView.frame = CGRect(x: 9, y: 0, width: view.bounds.width, height: 1)
    return footerView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1
  }
}

// MARK: - UITableViewDelegate

extension ChartListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chart = charts[indexPath.row]
    let title = "Chart #\(indexPath.row + 1)"
    delegate?.chartListViewController(self, didSelectChart: chart, title: title)
  }
}
