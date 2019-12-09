//
//  CruxClient.swift
//  CruxPay
//
//  Created by Sanchay on 21/11/19.
//

import Foundation
import JavaScriptCore

public class CruxClient {
    private let jsBridge: CruxJSBridge
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public init(configBuilder: CruxClientInitConfig.Builder) {
        self.jsBridge = CruxJSBridge(configBuilder: configBuilder)
    }
    
    func getJSONData(jsObj: JSValue) -> Data {
        let swiftDict = jsObj.toDictionary()
        let data = try! JSONSerialization.data(withJSONObject: swiftDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        return data
    }
    
    func getCruxErrorFromJsError(jsError: JSValue) -> CruxClientError {
        return CruxClientError(message: jsError.objectForKeyedSubscript("message").toString(), errorCode: jsError.objectForKeyedSubscript("errorCode").toString(), stack: jsError.objectForKeyedSubscript("stack").toString(), name: jsError.objectForKeyedSubscript("name").toString())
    }
    
    public func getCruxIDState(onResponse: @escaping (CruxIDState) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let cruxState: CruxIDState = try! decoder.decode(CruxIDState.self, from: data)
            onResponse(cruxState)
        }
        
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        self.jsBridge.executeAsync(method: "getCruxIDState", params: [], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func isCruxIDAvailable(cruxIDSubdomain: String, onResponse: @escaping (Bool) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let cruxIDAvailable = jsObj.toBool()
            onResponse(cruxIDAvailable)
        }
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        self.jsBridge.executeAsync(method: "isCruxIDAvailable", params: [cruxIDSubdomain], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func getAddressMap(onResponse: @escaping ([String: Address]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: Address] = try! decoder.decode([String: Address].self, from: data)
            onResponse(addressMap)
        }
       func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        self.jsBridge.executeAsync(method: "getAddressMap", params: [], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func putAddressMap(newAddressMap: [String: Address], onResponse: @escaping ([String: [String: Address]]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: [String: Address]] = try! decoder.decode([String: [String: Address]].self, from: data)
            onResponse(addressMap)
        }
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        let data = try! encoder.encode(newAddressMap)
        let addressMap = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        self.jsBridge.executeAsync(method: "putAddressMap", params: [addressMap], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func registerCruxID(cruxIDSubdomain: String, onResponse: @escaping () -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            if jsObj.isUndefined {
                onResponse()
            } else {
                print(jsObj)
            }
        }
       func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        self.jsBridge.executeAsync(method: "registerCruxID", params: [cruxIDSubdomain], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func resolveCurrencyAddressForCruxID(fullCruxID: String, walletCurrencySymbol: String, onResponse: @escaping (Address) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let address: Address = try! decoder.decode(Address.self, from: data)
            onResponse(address)
        }
       func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        self.jsBridge.executeAsync(method: "resolveCurrencyAddressForCruxID", params: [fullCruxID, walletCurrencySymbol], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
}
