//
//  ViewController.swift
//  Example
//
//  Created by lidaye on 22/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit

class TestsTableViewController: UITableViewController {
    
    let dao = DaoManager.sharedInstance
    
    var tests: [Test] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tests = dao.testDao.findAll()
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = tests[indexPath.row].content
        return cell
    }

}

