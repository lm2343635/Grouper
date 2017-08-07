//
//  SettingsTableViewController.swift
//  Example
//
//  Created by lidaye on 05/08/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit
import Grouper

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var serversLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var serversStepper: UIStepper!
    @IBOutlet weak var thresholdStepper: UIStepper!
    
    let grouper = Grouper.sharedInstance()!
    let dao = DaoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serversLabel.text = String(grouper.group.defaults.serverCount)
        thresholdLabel.text = String(grouper.group.defaults.threshold)
        serversStepper.value = Double(grouper.group.defaults.serverCount)
        thresholdStepper.value = Double(grouper.group.defaults.threshold)
        serversStepper.maximumValue = Double(grouper.group.defaults.servers.count)
        thresholdStepper.maximumValue = Double(grouper.group.defaults.serverCount)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    // MARK: - Action
    @IBAction func changeServer(_ sender: UIStepper) {
        if thresholdStepper.value > sender.value {
            thresholdStepper.value = sender.value
            thresholdLabel.text = String(format:"%.0f", sender.value)
        }
        serversLabel.text = String(format:"%.0f", sender.value)
        thresholdStepper.maximumValue = sender.value
        
        grouper.group.defaults.serverCount = Int(sender.value)
    }
    
    @IBAction func changeThreshold(_ sender: UIStepper) {
        thresholdLabel.text = String(format:"%.0f", sender.value)

        grouper.group.defaults.threshold = Int(sender.value)
    }
    
    @IBAction func clearEntites(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure to remove all test entities?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive) { (action) in
            self.dao.testDao.deleteAll()
            self.grouper.group.clear()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
