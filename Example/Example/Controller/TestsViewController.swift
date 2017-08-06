//
//  ViewController.swift
//  Example
//
//  Created by lidaye on 22/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit
import Grouper
import ESPullToRefresh
import Floaty

class TestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let grouper = Grouper.sharedInstance()!
    let dao = DaoManager.sharedInstance
    
    var tests: [Test] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.es_addPullToRefresh {
            self.grouper.receiver.receive {(count, processing) in
                // Callback function after receiving objects successfully.
                self.tests = self.dao.testDao.findAll()
                
                self.tableView.reloadData()
                self.tableView.es_stopPullToRefresh()

                self.showAlert(withTitle: "Received \(count) Messages",
                    andContent: "Scheme: f(\(self.grouper.group.defaults.threshold), \(self.grouper.group.defaults.serverCount))\n"
                        + "Data Sync: \(processing?.sync ?? 0)\n"
                        + "SecretSharing: \(processing?.secret ?? 0)\n"
                        + "Network: \(processing?.network ?? 0)\n"
                        + "Total: \(processing?.total ?? 0)")
            }
            
        }
        tableView.es_startPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tests = dao.testDao.findAll()
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = tests[indexPath.row].content
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let test = tests[indexPath.row]
        if editingStyle == .delete {
            grouper.sender.delete(test)
            tests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - Action
    @IBAction func manageMemebers(_ sender: Any) {
        self.present(grouper.ui.members.instantiateInitialViewController()!, animated: true, completion: nil)
    }

    @IBAction func addTest(_ sender: Any) {
        self.performSegue(withIdentifier: "addTestSegue", sender: self)
    }
    
}

