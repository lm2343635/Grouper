//
//  SyncTool.swift
//  GroupFinance
//
//  Created by lidaye on 05/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import Sync

@objc class SyncTool: NSObject {
    
    let dao = DaoManager.sharedInstance()
    var dataStack: DataStack
    
    init(dataStack: DataStack) {
        self.dataStack = dataStack
    }
    
    public func syncWithMessageData(_ message:MessageData) -> Bool {
        let content = serializeJSON(message.content)
        if content == nil {
            return false
        }
        switch message.type {
        case "update":
            Sync.changes([content!],
                         inEntityNamed: message.object,
                         dataStack: dataStack,
                         operations: [.insert, .update],
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
