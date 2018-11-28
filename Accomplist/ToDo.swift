//
//  ToDo.swift
//  Accomplist
//
//  Created by Colin on 2018-11-27.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import Foundation

struct Keys {
    static let toDoDescription = "description"
    static let isCompleted = "isCompleted"
    static let alertDate = "alertDate"
    static let isAlertSet = "isAlertSet"
}
class ToDo: NSObject, NSCoding {
    
    override init() {
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.toDoDescription, forKey: Keys.toDoDescription)
        aCoder.encode(self.isCompleted, forKey: Keys.isCompleted)
        aCoder.encode(self.alertDate, forKey: Keys.alertDate)
        aCoder.encode(self.isAlertSet, forKey: Keys.isAlertSet)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.toDoDescription = aDecoder.decodeObject(forKey: Keys.toDoDescription) as! String
        self.isCompleted = aDecoder.decodeBool(forKey: Keys.isCompleted)
        self.alertDate = aDecoder.decodeObject(forKey: Keys.alertDate) as! Date
        self.isAlertSet = aDecoder.decodeBool(forKey: Keys.isAlertSet)
    }
    
    var toDoDescription = ""
    var isCompleted = false
    var alertDate = Date()
    var isAlertSet = false
    
    
}
