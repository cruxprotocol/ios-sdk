//
//  CruxJSBridge.swift
//  CruxPay
//
//  Created by Sanchay on 14/11/19.
//

import Foundation
import JavaScriptCore
import CryptoSwift
import os

class CruxJSBridge {
    
    let cruxJsFileName: String = "cruxpay-0.2.8"
    var context: JSContext? = nil
    
    func getJSContext() throws -> JSContext {
        let context = JSContext()
        
        let frameworkBundle = Bundle(for: type(of: self))
        let bundleURL = frameworkBundle.resourceURL!.appendingPathComponent("CruxPay.bundle")
        let resourceBundle = Bundle(url: bundleURL)
        
        guard let cruxJSPath = resourceBundle?.path(forResource: cruxJsFileName, ofType: "js"),
            let requestDepsPath = resourceBundle?.path(forResource: "requestDeps", ofType: "js"),
            let promiseDepsPath = resourceBundle?.path(forResource: "promiseDeps", ofType: "js") else {
                throw CruxError(message: "Unexpected error: unable to read resource files.")
        }
        
        let requestDeps = try! String(contentsOfFile: requestDepsPath)
        let promiseDeps = try! String(contentsOfFile: promiseDepsPath)
        _ = context?.evaluateScript("var log = {debug: function(message) { _logDebug(message) }, info: function(message) { _logInfo(message) }, error: function(message) { _logError(message) } }")
        
        let logDebug: @convention(block) (String) -> Void = { message in
            os_log("%s", log: OSLog.default, type: .debug, message)
        }
        let logError: @convention(block) (String) -> Void = { message in
            os_log("%s", log: OSLog.default, type: .error, message)
        }
        let logInfo: @convention(block) (String) -> Void = { message in
            os_log("%s", log: OSLog.default, type: .info, message)
        }
        
        context?.exceptionHandler = { (ctx: JSContext!, value: JSValue!) in
            // type of String
            let stacktrace = value.objectForKeyedSubscript("stack").toString()
            // type of Number
            let lineNumber = value.objectForKeyedSubscript("line")
            // type of Number
            let column = value.objectForKeyedSubscript("column")
            let moreInfo = "in method \(String(describing: stacktrace))Line number in file: \(String(describing: lineNumber)), column: \(String(describing: column))"
            let message = "JS ERROR: \(String(describing: value)) \(moreInfo)"
            os_log("%s", log: OSLog.default, type: .error, message)
        }
        
        context?.setObject(unsafeBitCast(logDebug, to: AnyObject.self),
                           forKeyedSubscript: "_logDebug" as NSCopying & NSObjectProtocol)
        context?.setObject(unsafeBitCast(logError, to: AnyObject.self),
                           forKeyedSubscript: "_logError" as NSCopying & NSObjectProtocol)
        context?.setObject(unsafeBitCast(logInfo, to: AnyObject.self),
                           forKeyedSubscript: "_logInfo" as NSCopying & NSObjectProtocol)
        _ = context?.evaluateScript("var window = this;")
        _ = context?.evaluateScript(requestDeps)
        _ = context?.evaluateScript(promiseDeps)
        JSFetch.provideToContext(context: context!)
        JSIntervals.provideToContext(context: context!)
        
        let cruxJS = try! String(contentsOfFile: cruxJSPath)
        _ = context?.evaluateScript("var crypto = { getRandomValues: function(bytes) { return _getRandomValues(bytes) } }")
        let getRandomValues: @convention(block) (Array<UInt8>) -> Array<UInt8> = { arr in
            let count = arr.count
            return AES.randomIV(count)
        }
        context?.setObject(unsafeBitCast(getRandomValues, to: AnyObject.self),
                                 forKeyedSubscript: "_getRandomValues" as (NSCopying & NSObjectProtocol)?)
        _ = context?.evaluateScript(cruxJS)
        
        return context!
    }
    
    init(configBuilder: CruxClientInitConfig.Builder) {
        context = try! getJSContext()
        prepareCruxClientInitConfig(configBuilder: configBuilder)
        context?.evaluateScript("cruxClient = new window.CruxPay.CruxClient(cruxClientInitConfig)")
    }
    private func prepareCruxClientInitConfig(configBuilder: CruxClientInitConfig.Builder) -> Void {
        var cruxClientInitConfig: CruxClientInitConfig  = configBuilder.create();
        var cruxClientInitConfigString: String
        cruxClientInitConfigString = cruxClientInitConfig.getCruxClientInitConfigString()!;
        if (!cruxClientInitConfigString.isEmpty) {
            context?.evaluateScript("cruxClientInitConfig = \(cruxClientInitConfigString);")
            context?.evaluateScript("cruxClientInitConfig['storage'] = inmemStorage;")
            cruxClientInitConfigString = ""
        }
    }
    
    
    public func executeAsync(method: String, params: [Any], onResponse: @escaping (JSValue) -> (), onErrorResponse: @escaping (JSValue) -> ()) {
        let successCallback: @convention (block)(JSValue) -> () = onResponse
        context?.setObject(successCallback, forKeyedSubscript: "jsSuccessHandler" as NSString)
        let jsSuccessCallback = context?.objectForKeyedSubscript("jsSuccessHandler")!
        
        let failureCallback: @convention (block)(JSValue) -> () = onErrorResponse
        context?.setObject(failureCallback, forKeyedSubscript: "jsFailureHandler" as NSString)
        let jsFailureCallback = context?.objectForKeyedSubscript("jsFailureHandler")!
        
        let jsClient: JSValue = (context?.evaluateScript("cruxClient"))!
        let jsMethod = jsClient.objectForKeyedSubscript(method)
        let promise = jsMethod?.call(withArguments: params)
        promise?.invokeMethod("then", withArguments: [jsSuccessCallback!])
        promise?.invokeMethod("catch", withArguments: [jsFailureCallback!])
    }
}
