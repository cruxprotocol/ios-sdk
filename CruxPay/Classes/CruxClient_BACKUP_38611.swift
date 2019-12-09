//
//  CruxClient.swift
//  CruxPay
//
//  Created by Sanchay on 21/11/19.
//

import Foundation
import JavaScriptCore

public class CruxClient {
<<<<<<< HEAD
    private let jsBridge: CruxJS
=======
    private let jsBridge: CruxJSBridge
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public init(configBuilder: CruxClientInitConfig.Builder) {
<<<<<<< HEAD
        self.jsBridge = CruxJS(configBuilder: configBuilder)
=======
        self.jsBridge = CruxJSBridge(configBuilder: configBuilder)
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
    }
    
    func getJSONData(jsObj: JSValue) -> Data {
        let swiftDict = jsObj.toDictionary()
        let data = try! JSONSerialization.data(withJSONObject: swiftDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        return data
    }
    
<<<<<<< HEAD
=======
    func getCruxErrorFromJsError(jsError: JSValue) -> CruxClientError {
        return CruxClientError(message: jsError.objectForKeyedSubscript("message").toString(), errorCode: jsError.objectForKeyedSubscript("errorCode").toString(), stack: jsError.objectForKeyedSubscript("stack").toString(), name: jsError.objectForKeyedSubscript("name").toString())
    }
    
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
    public func getCruxIDState(onResponse: @escaping (CruxIDState) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let cruxState: CruxIDState = try! decoder.decode(CruxIDState.self, from: data)
            onResponse(cruxState)
        }
<<<<<<< HEAD
        func error_callback_fn (jsObj: JSValue) -> () {
            print(jsObj)
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
=======
        
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
        }
        self.jsBridge.executeAsync(method: "getCruxIDState", params: [], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func isCruxIDAvailable(cruxIDSubdomain: String, onResponse: @escaping (Bool) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let cruxIDAvailable = jsObj.toBool()
            onResponse(cruxIDAvailable)
        }
<<<<<<< HEAD
        func error_callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
=======
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
        }
        self.jsBridge.executeAsync(method: "isCruxIDAvailable", params: [cruxIDSubdomain], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func getAddressMap(onResponse: @escaping ([String: Address]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: Address] = try! decoder.decode([String: Address].self, from: data)
            onResponse(addressMap)
        }
<<<<<<< HEAD
        func error_callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
=======
       func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
        }
        self.jsBridge.executeAsync(method: "getAddressMap", params: [], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func putAddressMap(newAddressMap: [String: Address], onResponse: @escaping ([String: [String: Address]]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: [String: Address]] = try! decoder.decode([String: [String: Address]].self, from: data)
            onResponse(addressMap)
        }
<<<<<<< HEAD
        func error_callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
=======
        func error_callback_fn(jsObj: JSValue) -> () {
            let cruxError = getCruxErrorFromJsError(jsError: jsObj)
            onErrorResponse(cruxError)
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
        }
        let data = try! encoder.encode(newAddressMap)
        let addressMap = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        self.jsBridge.executeAsync(method: "putAddressMap", params: [addressMap], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
<<<<<<< HEAD
//    public func getCruxIDState(handler: CruxClientResponseHandler) -> Void {
//    public func getCruxIDState(handler: (ICruxClientResponseHandler)) -> Void {
//    public func getCruxIDState<T: CruxIDState, U: ICruxClientResponseHandler>(handler: T) -> Void {
//        typealias T = CruxIDState
//    public func getCruxIDState<C1: CruxClientResponseHandler>(handler: C1) -> Void {
//        let bridgeRequest: CruxJSBridgeAsyncRequest = CruxJSBridgeAsyncRequest(method: "getCruxIDState", params: CruxParams(), handler: CruxJSBridgeResponseHandler)
        // jsBridge.executeAsync()
//    }
=======
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
>>>>>>> d7c1916e78d88d0525aee9342e03f02efd38cc03
}
