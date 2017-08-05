//
//  SettingsTableViewController.swift
//  Example
//
//  Created by lidaye on 05/08/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var serversLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    // MARK: - Action
    @IBAction func changeServer(_ sender: Any) {
        
    }
    
    @IBAction func changeThreshold(_ sender: Any) {
        
    }
    
}
