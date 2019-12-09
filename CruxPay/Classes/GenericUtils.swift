//
//  GenericUtils.swift
//  CruxPay
//
//  Created by Sanchay on 25/11/19.
//

import Foundation
import JavaScriptCore

public class GenericUtils {
    public static func toSwiftObject(val: JSValue) -> Any {
        if val.isObject {
            return val.toObject();
        } else if val.isBoolean {
            return val.toBool()
        } else if val.isString {
            return val.toString()
        } else if val.isNumber {
            return val.toDouble()
        } else {
            return val
        }
    }
}
