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
    
    func executeAsyncWithErrorCallback(method: String, params: [Any], callback_fn: @escaping (JSValue) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
        }
        self.jsBridge.executeAsync(method: method, params: params, onResponse: callback_fn, onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func getCruxIDState(onResponse: @escaping (CruxIDState) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let cruxState: CruxIDState = try! decoder.decode(CruxIDState.self, from: data)
            onResponse(cruxState)
        }
        executeAsyncWithErrorCallback(method: "getCruxIDState", params: [], callback_fn: callback_fn(jsObj:), onErrorResponse: onErrorResponse)
    }
    
    public func isCruxIDAvailable(cruxIDSubdomain: String, onResponse: @escaping (Bool) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let cruxIDAvailable = jsObj.toBool()
            onResponse(cruxIDAvailable)
        }
        executeAsyncWithErrorCallback(method: "isCruxIDAvailable", params: [cruxIDSubdomain], callback_fn: callback_fn(jsObj:), onErrorResponse: onErrorResponse)
    }
    
    public func getAddressMap(onResponse: @escaping ([String: Address]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: Address] = try! decoder.decode([String: Address].self, from: data)
            onResponse(addressMap)
        }
        executeAsyncWithErrorCallback(method: "getAddressMap", params: [], callback_fn: callback_fn(jsObj:), onErrorResponse: onErrorResponse)
    }
    
    public func putAddressMap(newAddressMap: [String: Address], onResponse: @escaping ([String: [String: Address]]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: [String: Address]] = try! decoder.decode([String: [String: Address]].self, from: data)
            onResponse(addressMap)
        }
        let data = try! encoder.encode(newAddressMap)
        let addressMap = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        executeAsyncWithErrorCallback(method: "putAddressMap", params: [addressMap], callback_fn: callback_fn(jsObj:), onErrorResponse: onErrorResponse)
    }
    
    public func registerCruxID(cruxIDSubdomain: String, onResponse: @escaping () -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            onResponse()
        }
        executeAsyncWithErrorCallback(method: "registerCruxID", params: [cruxIDSubdomain], callback_fn: callback_fn(jsObj:), onErrorResponse: onErrorResponse)
    }
    
    public func resolveCurrencyAddressForCruxID(fullCruxID: String, walletCurrencySymbol: String, onResponse: @escaping (Address) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let address: Address = try! decoder.decode(Address.self, from: data)
            onResponse(address)
        }
        executeAsyncWithErrorCallback(method: "resolveCurrencyAddressForCruxID", params: [fullCruxID, walletCurrencySymbol], callback_fn: callback_fn(jsObj:), onErrorResponse: onErrorResponse)
    }
}
