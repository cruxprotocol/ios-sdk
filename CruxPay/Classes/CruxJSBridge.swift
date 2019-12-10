//
//  CruxJSBridge.swift
//  CruxPay
//
//  Created by Sanchay on 14/11/19.
//

import Foundation
import JavaScriptCore
import CryptoSwift

class CruxJSBridge {
    lazy var context: JSContext? = {
        let context = JSContext()
        
        let frameworkBundle = Bundle(for: type(of: self))
        let bundleURL = frameworkBundle.resourceURL!.appendingPathComponent("CruxPay.bundle")
        let resourceBundle = Bundle(url: bundleURL)
        
        guard let cruxJSPath = resourceBundle?.path(forResource: "cruxpay-0.1.5", ofType: "js"),
            let requestDepsPath = resourceBundle?.path(forResource: "requestDeps", ofType: "js"),
            let promiseDepsPath = resourceBundle?.path(forResource: "promiseDeps", ofType: "js") else {
                print("unable to read resource files.")
                return nil
        }
        
        let requestDeps = try! String(contentsOfFile: requestDepsPath)
        let promiseDeps = try! String(contentsOfFile: promiseDepsPath)
        _ = context?.evaluateScript("var console = {log: function(message) { _consoleLog(message) }, warn: function(message) { _consoleLog(message) } }")
        
        let consoleLog: @convention(block) (String) -> Void = { message in
            print("console.log: " + message)
        }
        context?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self),
           forKeyedSubscript: "_consoleLog" as NSCopying & NSObjectProtocol)
        _ = context?.evaluateScript("var window = this;")
        _ = context?.evaluateScript(requestDeps)
        _ = context?.evaluateScript(promiseDeps)
        JSFetch.provideToContext(context: context!, hostURL: "https://www.cruxpay.com")
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
        
        return context
    }()
    
    init(configBuilder: CruxClientInitConfig.Builder) {
        prepareCruxClientInitConfig(configBuilder: configBuilder)
        context?.evaluateScript("cruxClient = new window.CruxPay.CruxClient(cruxClientInitConfig)")
        context?.evaluateScript("""
            cruxClient.init()
            .then(() => {
                console.log('CruxClient initialized');
            }).catch((err) => {
                console.log('CruxClient error', err);
                console.log(JSON.stringify(err));
            })
        """)
    }
    private func prepareCruxClientInitConfig(configBuilder: CruxClientInitConfig.Builder) -> Void {
        let cruxClientInitConfig: CruxClientInitConfig  = configBuilder.create();
        var cruxClientInitConfigString: String
        cruxClientInitConfigString = cruxClientInitConfig.getCruxClientInitConfigString()!;
        if (!cruxClientInitConfigString.isEmpty) {
            context?.evaluateScript("cruxClientInitConfig = \(cruxClientInitConfigString);")
            context?.evaluateScript("cruxClientInitConfig['storage'] = inmemStorage;")
            context?.evaluateScript("cruxClientInitConfig['getEncryptionKey'] = function() { return 'fookey';}")
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
        promise?.invokeMethod("then", withArguments: [jsSuccessCallback])
        promise?.invokeMethod("catch", withArguments: [jsFailureCallback])
    }
}
