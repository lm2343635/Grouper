//
//  SyncTool.swift
//  GroupFinance
//
//  Created by lidaye on 05/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import Sync
import DATAStack

@objc class SyncTool: NSObject {
    
    var dataStack: DATAStack
    
    init(dataStack: DATAStack) {
        self.dataStack = dataStack
    }
    
    public func syncWithMessage(_ messageString:String, sender: String) -> Bool {
        let messageDictionary = serializeJSON(messageString)
        if messageDictionary == nil {
            return false
        }
        let message = Message(dictionary: messageDictionary, sender: sender)!
        let content = serializeJSON(message.content)
        if content == nil {
            return false
        }
        switch message.type {
        case "update":
            Sync.changes([content!],
                         inEntityNamed: message.object,
                         dataStack: dataStack,
                         operations: [.Insert, .Update],
                         completion: nil)
        case "delete":
            do {
                let remoteID = content?["id"] as! String
                try Sync.delete(remoteID, inEntityNamed: message.object, using: dataStack.mainContext)
            } catch _ {
                return false
            }
        default:
            return false
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedNewObject"), object: message);
        return true
    }
    
    //Transfer JSON string to dictionary
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
