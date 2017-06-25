//
//  Sync+ObjC.swift
//  Pods
//
//  Created by lidaye on 25/06/2017.
//
//

import Sync

public extension Sync {
    
    public class func changesOnlyInsertUpdate(_ changes: [[String: Any]], inEntityNamed entityName: String, dataStack: DataStack, completion: ((_ error: NSError?) -> Void)?) {
        self.changes(changes, inEntityNamed: entityName, predicate: nil, dataStack: dataStack, operations: [.insert, .update], completion: completion)
    }

}
