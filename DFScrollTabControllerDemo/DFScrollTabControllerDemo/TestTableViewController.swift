//
//  TestTableViewController.swift
//  DFScrollTabControllerDemo
//
//  Created by Fuxp on 2018/8/28.
//  Copyright © 2018年 fuxp. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(title!, #function)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(title!, #function)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(title!, #function)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(title!, #function)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(title!, #function)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = "\(title!) - \(indexPath.row)"

        return cell
    }
}
