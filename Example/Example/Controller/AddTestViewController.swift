//
//  AddTestViewController.swift
//  Example
//
//  Created by 李大爷的电脑 on 22/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import UIKit
import Grouper

class AddTestViewController: UIViewController {

    @IBOutlet weak var testNumberTextField: UITextField!
    
    let dao = DaoManager.sharedInstance
    let grouper = Grouper.sharedInstance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testNumberTextField.resignFirstResponder()
    }

    @IBAction func createTests(_ sender: Any) {
        if testNumberTextField.text == "" {
            return
        }
        var testNumber = Int(testNumberTextField.text!) ?? 0
        if testNumber < 1 {
            return
        }
        var tests:[Test] = []
        while testNumber > 0 {
            tests.append(dao.testDao.saveWithContent(Date().description))
            testNumber = testNumber - 1
        }
        grouper.sender.updateAll(tests)
        navigationController?.popViewController(animated: true)
    }
    
}
