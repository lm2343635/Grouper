//
//  testDao.swift
//  Example
//
//  Created by lidaye on 22/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import CoreData

class TestDao: DaoTemplate {

    func saveWithContent(_ content: String) -> Test {
        let test = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Test.self),
                                                       into: context) as? Test
        test?.content = content
        self.saveContext()
        return test!
    }
    
    func findAll() -> [Test] {
        let request = NSFetchRequest<Test>(entityName: NSStringFromClass(Test.self))
        request.sortDescriptors = [NSSortDescriptor(key: "createAt", ascending: false)]
        return try! context.fetch(request)
    }
    
    func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(Test.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try! context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
    }
    
}
