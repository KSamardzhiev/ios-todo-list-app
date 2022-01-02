//
//  Category.swift
//  ToDoList
//
//  Created by Kostadin Samardzhiev on 2.01.22.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
