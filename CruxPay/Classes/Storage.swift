//
//  Storage.swift
//  CruxPay
//
//  Created by Sanchay on 22/11/19.
//

import Foundation
import JavaScriptCore

@objc protocol StorageJSExport: JSExport {
    static func getItemWith(key: String) -> String
    static func setItemWith(key: String, value: String) -> Void
}

class Storage: NSObject, StorageJSExport {
    static func getItemWith(key: String) -> String {
        if let value = UserDefaults.standard.string(forKey: key) {
            return value
        }
        return ""
    }
    static func setItemWith(key: String, value: String) -> Void {
        UserDefaults.standard.set(value, forKey: key)
    }
}
