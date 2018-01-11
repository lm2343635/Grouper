//
//  AddTestViewController.swift
//  Example
//
//  Created by 李大爷的电脑 on 22/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit
import Grouper
import NVActivityIndicatorView

class AddTestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var testNumberTextField: UITextField!
    @IBOutlet weak var processingTableView: UITableView!
    
    let dao = DaoManager.sharedInstance
    let grouper = Grouper.sharedInstance()!
    var processing: Processing?
    var result = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testNumberTextField.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return processing == nil ? 0 : 6
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - UITableViewDataDelegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "processingCell")
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Scheme"
            cell.detailTextLabel?.text = "f(\(grouper.group.defaults.threshold), \(grouper.group.defaults.serverCount), \(grouper.group.defaults.safeServerCount))"
        case 1:
            cell.textLabel?.text = "Data Sync"
            cell.detailTextLabel?.text = "\(processing?.sync ?? 0)"
        case 2:
            cell.textLabel?.text = "Secret Sharing"
            cell.detailTextLabel?.text = "\(processing?.secret ?? 0)"
        case 3:
            cell.textLabel?.text = "Network"
            cell.detailTextLabel?.text = "\(processing?.network ?? 0)"
        case 4:
            cell.textLabel?.text = "Total"
            cell.detailTextLabel?.text = "\(processing?.total ?? 0)"
        case 5:
            cell.textLabel?.text = "Result"
            cell.detailTextLabel?.text = result ? "success" : "fail"
        default:
            break
        }
        return cell
    }

    // MARK: - Action
    @IBAction func createTests(_ sender: Any) {
        if testNumberTextField.text == "" {
            return
        }
        var testNumber = Int(testNumberTextField.text!) ?? 0
        if testNumber < 1 {
            return
        }
        startAnimating()
        testNumberTextField.resignFirstResponder()
        var tests:[Test] = []
        while testNumber > 0 {
            tests.append(dao.testDao.saveWithContent(Date().description))
            testNumber = testNumber - 1
        }
        grouper.sender.updateAll(tests) { (processing, success) in
            self.stopAnimating()
            self.processing = processing
            self.processingTableView.reloadData()
            self.result = success
        }
    }
    
}
