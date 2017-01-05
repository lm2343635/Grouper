//
//  SyncTool.swift
//  GroupFinance
//
//  Created by lidaye on 05/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import UIKit
import Sync
import DATAStack

@objc class SyncTool: NSObject {
    
    var dataStack: DATAStack
    
    init(dataStack: DATAStack) {
        self.dataStack = dataStack
    }
    
    public func syncWithMessage(_ messageString:String) {
        let message = serializeJSON(messageString)
        if message == nil {
            return
        }
        let content = serializeJSON(message!["content"] as! String)
        if content == nil {
            return
        }
        Sync.changes([content!],
                     inEntityNamed: message!["object"] as! String,
                     dataStack: dataStack,
                     operations: [.Insert, .Update],
                     completion: nil)
    }
    
    func serializeJSON(_ string: String) -> [String: Any]? {
        if let data = string.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
