//
//  CruxClient.swift
//  CruxPay
//
//  Created by Sanchay on 21/11/19.
//

import Foundation
import JavaScriptCore

public class CruxClient {
    private let jsBridge: CruxJS
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public init(configBuilder: CruxClientInitConfig.Builder) {
        self.jsBridge = CruxJS(configBuilder: configBuilder)
    }
    
    func getJSONData(jsObj: JSValue) -> Data {
        let swiftDict = jsObj.toDictionary()
        let data = try! JSONSerialization.data(withJSONObject: swiftDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        return data
    }
    
    public func getCruxIDState(onResponse: @escaping (CruxIDState) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let cruxState: CruxIDState = try! decoder.decode(CruxIDState.self, from: data)
            onResponse(cruxState)
        }
        func error_callback_fn (jsObj: JSValue) -> () {
            print(jsObj)
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
        }
        self.jsBridge.executeAsync(method: "getCruxIDState", params: [], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func isCruxIDAvailable(cruxIDSubdomain: String, onResponse: @escaping (Bool) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let cruxIDAvailable = jsObj.toBool()
            onResponse(cruxIDAvailable)
        }
        func error_callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
        }
        self.jsBridge.executeAsync(method: "isCruxIDAvailable", params: [cruxIDSubdomain], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func getAddressMap(onResponse: @escaping ([String: Address]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: Address] = try! decoder.decode([String: Address].self, from: data)
            onResponse(addressMap)
        }
        func error_callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
        }
        self.jsBridge.executeAsync(method: "getAddressMap", params: [], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
    public func putAddressMap(newAddressMap: [String: Address], onResponse: @escaping ([String: [String: Address]]) -> (), onErrorResponse: @escaping (CruxClientError) -> ()) {
        func callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let addressMap: [String: [String: Address]] = try! decoder.decode([String: [String: Address]].self, from: data)
            onResponse(addressMap)
        }
        func error_callback_fn (jsObj: JSValue) -> () {
            let data = getJSONData(jsObj: jsObj)
            let myStruct: CruxClientError = try! decoder.decode(CruxClientError.self, from: data)
            onErrorResponse(myStruct)
        }
        let data = try! encoder.encode(newAddressMap)
        let addressMap = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        self.jsBridge.executeAsync(method: "putAddressMap", params: [addressMap], onResponse: callback_fn(jsObj:), onErrorResponse: error_callback_fn(jsObj:))
    }
    
//    public func getCruxIDState(handler: CruxClientResponseHandler) -> Void {
//    public func getCruxIDState(handler: (ICruxClientResponseHandler)) -> Void {
//    public func getCruxIDState<T: CruxIDState, U: ICruxClientResponseHandler>(handler: T) -> Void {
//        typealias T = CruxIDState
//    public func getCruxIDState<C1: CruxClientResponseHandler>(handler: C1) -> Void {
//        let bridgeRequest: CruxJSBridgeAsyncRequest = CruxJSBridgeAsyncRequest(method: "getCruxIDState", params: CruxParams(), handler: CruxJSBridgeResponseHandler)
        // jsBridge.executeAsync()
//    }
}
