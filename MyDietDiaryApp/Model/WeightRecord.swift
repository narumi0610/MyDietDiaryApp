//
//  WeightRecord.swift
//  MyDietDiaryApp
//
//  Created by mac on 2023/03/27.
//

import Foundation
import RealmSwift

class WeightRecord: Object {
    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var weight: Double = 0
 }
