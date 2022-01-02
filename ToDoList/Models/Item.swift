//
//  Item.swift
//  ToDoList
//
//  Created by Kostadin Samardzhiev on 2.01.22.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var checked: Bool = false
    @objc dynamic var dateCreated: Double = 0
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
