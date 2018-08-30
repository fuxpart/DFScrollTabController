//
//  ViewController.swift
//  DFScrollTabControllerDemo
//
//  Created by fuxp on 2018/8/27.
//  Copyright © 2018 fuxp. All rights reserved.
//

import UIKit
import DFScrollTabController

class ViewController: UIViewController, ScrollTabControllerDataSource {

    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func scrollable(_ sender: UIButton) {
        count = 10
        let tabBar = ScrollableTabBar()
        let style = ScrollTabControllerStyle(scrollEnabled: false)
        let controller = ScrollTabController(style: style, tabBar: tabBar)
        tabBar.scrollTabController = controller
        controller.dataSource = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func fixed(_ sender: UIButton) {
        count = 4
        let tabBar = FixedTabBar()
        let controller = ScrollTabController(tabBar: tabBar)
        tabBar.scrollTabController = controller
        controller.dataSource = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func numberOfControllers(for tabController: ScrollTabController) -> Int {
         return count
    }

    func tabController(_ tab: ScrollTabController, titleForControllerAt index: Int) -> ScrollTabBarTitleItem {
        return "index \(index)"
    }

    func tabController(_ tab: ScrollTabController, viewControllAt index: Int) -> UIViewController {
        let vc = TestTableViewController()
        vc.title = "controller at index \(index)"
        return vc
    }
}

