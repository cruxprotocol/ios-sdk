import Foundation
import AuthenticationServices
import SafariServices
import JavaScriptCore
//import CryptoSwift
//import Promises

public typealias Bytes = Array<UInt8>

//@objc protocol StorageJSExport: JSExport {
//    static func getItemWith(key: String) -> String
//    static func setItemWith(key: String, value: String) -> Void
//}
//
//class Storage: NSObject, StorageJSExport {
//    static func getItemWith(key: String) -> String {
//        if let value = UserDefaults.standard.string(forKey: key) {
//            return value
//        }
//        return ""
//    }
//    static func setItemWith(key: String, value: String) -> Void {
//        UserDefaults.standard.set(value, forKey: key)
//    }
//}

@objc protocol ResponseJSProtocol: JSExport {
    var status: NSNumber? { get set }
    
    func text() -> String?
}

class ResponseJS: NSObject, ResponseJSProtocol {
    @objc dynamic var status: NSNumber?
    @objc dynamic private var bodyText: String?

    init (text: String?, status: Int?) {
        self.bodyText = text
        self.status = status == nil ? nil : NSNumber(integerLiteral: status!)
    }
    
    func text() -> String? {
        return self.bodyText
    }
}

public class CruxClientOld {
    
    var jsContext: JSContext!
    
//    lazy var context: JSContext? = {
//        let context = JSContext()
//
////        let frameworkBundle = Bundle(for: type(of: self))
////        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("CruxPay.bundle")
////        let resourceBundle = Bundle(url: bundleURL!)
//
//        guard let
////            JSPath = Bundle.main.path(forResource: "cruxpay", ofType: "js") else {
//            JSPath = Bundle.main.path(forResource: "parcel-bundle", ofType: "js") else {
//                print("unable to read resource files.")
//                return nil
//        }
//
//        do {
//            print("Doing")
//            let cruxpayJS = try String(contentsOfFile: JSPath, encoding: String.Encoding.utf8)
//            _ = context?.evaluateScript(cruxpayJS)
//            _ = context?.evaluateScript("var window = this;")
//            _ = context?.evaluateScript("console.log('It Worked!');")
//            print("Done")
//
//        } catch (let error) {
//            print("Error while processing script file: \(error)")
//        }
//
//        context?.exceptionHandler = {(context: JSContext?, exception: JSValue?) -> Void in
//            print(exception!.toString())
//        }
//
//        _ = context?.evaluateScript("var console = {log: function(message) { _consoleLog(message) } }")
//
//        let consoleLog: @convention(block) (String) -> Void = { message in
//            print("console.log: " + message)
//        }
//
//        context?.setObject(unsafeBitCast(consoleLog, to: AnyObject.self),
//                           forKeyedSubscript: "_consoleLog" as NSCopying & NSObjectProtocol)
//        return context
//    }()
    
//    let nativeFetch: @convention(block) (JSValue?, JSValue?, JSValue?) -> () = { resolve, reject, jsURL in
//        guard let urlString = jsURL?.toString(),
//            let url = URL(string: urlString) else {
//                return
//        }
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                    _ = resolve?.call(withArguments: [
//                        ResponseJS(text: nil, status: statusCode)
//                        ])
//                } else {
//                    _ = reject?.call(withArguments: [
//                        JSValue(newErrorFromMessage: "Network request failed", in: self.jsContext)
//                        ])
//                }
//                return
//            }
//            let text = String(data: data, encoding: .utf8)
//            _ = resolve?.call(withArguments: [
//                ResponseJS(text: text, status: 200)
//                ])
//            }.resume()
//    }
    
    public init(walletName: String) {
        
        self.jsContext = JSContext()
        
        if let cruxJSPath = Bundle.main.path(forResource: "parcel-bundle", ofType: "js"),
            let cruxJS = try? String(contentsOfFile: cruxJSPath),
            let requestDepsPath = Bundle.main.path(forResource: "requestDeps", ofType: "js"),
            let requestDeps = try? String(contentsOfFile: requestDepsPath),
            let promiseDepsPath = Bundle.main.path(forResource: "promiseDeps", ofType: "js"),
            let promiseDeps = try? String(contentsOfFile: promiseDepsPath) {
            do {
                print("Found JS files")
                self.jsContext.evaluateScript("var window = this;")
                self.jsContext.exceptionHandler = {(context: JSContext?, exception: JSValue?) -> Void in
                    print(exception!.toString())
                } 
        
                _ = self.jsContext.evaluateScript("var console = {log: function(message) { _consoleLog(message) } }")
        
                let consoleLog: @convention(block) (String) -> Void = { message in
                    print("console.log: " + message)
                }
        
                self.jsContext.setObject(unsafeBitCast(consoleLog, to: AnyObject.self),
                                   forKeyedSubscript: "_consoleLog" as NSCopying & NSObjectProtocol)
                
//                _ = self.jsContext.evaluateScript("var crypto = { getRandomValues: function(bytes) { _getRandomValues(bytes) } }")
//                let getRandomValues: @convention(block) (Array<UInt8>) -> Void = { message in
//                    print("getRandomValues called")
//                }
//                let randomBytes: @convention(block) (Int) -> Array<UInt8> = { count in
//                    return AES.randomIV(count)
//                }
//                self.jsContext.setObject(unsafeBitCast(getRandomValues, to: AnyObject.self),
//                                         forKeyedSubscript: "_getRandomValues" as (NSCopying & NSObjectProtocol)?)
//                self.jsContext.setObject(unsafeBitCast(randomBytes, to: AnyObject.self),
//                                         forKeyedSubscript: "randomBytes" as (NSCopying & NSObjectProtocol)?)
//
                self.jsContext.evaluateScript(requestDeps)
                self.jsContext.evaluateScript(promiseDeps)
                JSFetch.provideToContext(context: self.jsContext, hostURL: "https://www.cruxpay.com")
                JSIntervals.provideToContext(context: self.jsContext)
                
                self.jsContext.evaluateScript(cruxJS)
                
                print("evaluated script")
            } catch (let error) {
                print("Error while processing script file: \(error)")
            }
        }
        
        self.jsContext.setObject(Storage.self, forKeyedSubscript: "Storage" as NSCopying & NSObjectProtocol)
        self.jsContext.evaluateScript("""
            class iOSLocalStorage extends window.CruxPay.storage.StorageService {
                constructor() {
                    super(...arguments);
                    this.setItem = async (key, value) => Storage.setItemWithKeyValue(key, value);
                    this.getItem = async (key) => Storage.getItemWithKey(key);
                }
            }
            const s = new iOSLocalStorage();
        """)
        self.jsContext.evaluateScript("s.setJSON('payIDClaim', {'identitySecrets':'{\\\"iv\\\":\\\"59ZAnVm5vyC6zIZz\\\",\\\"encBuffer\\\":\\\"1JstBA1vk8LpSfI9kPlGtWytcAZUbGN51g5E8NA/OVXjSsygdjdceeW0bb/2GbR9qkkq4P7nuP9lCjxbXWcsJaj/0AWUOA82AmZnbP7yUH8ATQwdSgyhUQDGboSVsO2JYFg1tPg2P+kA0jIoRYYGpAlcT8hhEe5jRSp9NBZ2cFWV/z3yDRMZtXHUQtwY/bPenREqBv7iBgwnqWLzrDMoY+KrjOXzUC3BWCByYfj02WkXLq6tQnJyPepCl1OGhpfoDCBgRbrIZ+uJxDp0RrAbp52OSREPaHPF/6oShTm5Pre1ZswBxufqwWMfNARY0wA=\\\"}','virtualAddress':'yadu007@cruxdev.crux'});")
        self.jsContext.evaluateScript("""
            console.log("Creating function getPassHashedEncryptionKey()");
            function getPassHashedEncryptionKey() {
                return 'fookey';
            }
            console.log("Setting CruxClientOptions");
            let cruxClientOptions = {
                getEncryptionKey: getPassHashedEncryptionKey,
                walletClientName: 'cruxdev',
                storage: s,
                // privateKey: "6bd397dc89272e71165a0e7d197b280c7a88ed5b1e44e1928c25455506f1968f"  // (optional parameter)
            }
            console.log("Making CruxClient object");
            let cruxClient = new window.CruxPay.CruxClient(cruxClientOptions);
        """)
        self.jsContext.evaluateScript("""
            console.log("Calling init now");
            cruxClient.init()
            .then(() => {
                console.log('CruxClient initialized');
            }).catch((err) => {
                console.log('CruxClient error', err);
                console.log(JSON.stringify(err));
            })
        """)
        sleep(5)
        print("Cruxclient object: ")
        print(self.jsContext.objectForKeyedSubscript("cruxClient"))
        print(self.jsContext.evaluateScript("cruxClient"))
    }
    
    
    
//    public static let shared = CruxClient()
    public func getCruxIDState() -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
        let res = self.jsContext.evaluateScript("cruxClient.getCruxIDState().then((res) => {console.log(JSON.stringify(res));}, (reason) => {console.log('reason failed: ');  console.log(JSON.stringify(reason));})")
        print(res!)
        return res?.toString()
    }
    public func isCruxIDAvailable(cruxID: String) -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
//        guard let jsCallback = JSValue(object: tester, in: self.jsContext),
//              let jsFunc = self.jsContext.objectForKeyedSubscript("cruxClient.isCruxIDAvailable"),
//              let _ = jsFunc.call(withArguments:[jsCallback])
//        else {
//                print("unable to call function")
//                return ""
//        }
//        let res = self.jsContext.evaluateScript("""
//            cruxClient.isCruxIDAvailable('\(cruxID)')
//            .then((res) => {
//                console.log('Res successful');
//                console.log(JSON.stringify(res));
//            }).catch((reason) => {
//                console.log('reason failed: ');
//                console.log(JSON.stringify(reason));
//            })
//        """)
//        print(res!)
//        return res?.toString()
//        executeAsync(callback_fn: tester)
        
//        let promise: Promise<JSValue>
        let callback: @convention (block)(JSValue) -> () = { (content: JSValue) in
            print("Request result: \(content.toBool())")
        }
//        self.jsContext.setObject(callback, forKeyedSubscript: "jsCallback" as NSString)
//        let jsCallback = self.jsContext.objectForKeyedSubscript("jsCallback")!
        
        let jsCallback = JSValue.init(object: callback, in: self.jsContext)
        
        var jsClient: JSValue = self.jsContext.evaluateScript("cruxClient")
        print("jsClient Set")
        print(jsClient)
        var jsMethod = jsClient.objectForKeyedSubscript("isCruxIDAvailable")
        print("jsMethod Set")
        print(jsMethod)
        var promise = jsMethod?.call(withArguments: ["ankit123"])
        print("Promise Set")
        print(promise)
//        var promiseThen = promise?.objectForKeyedSubscript("then")
//        print("PromiseThen Set")
//        print(promiseThen)
//        promiseThen?.call(withArguments: [callback])
        promise?.invokeMethod("then", withArguments: [jsCallback])
        print("promiseThen called")
        print(self.jsContext)
        
        
//        self.jsContext.evaluateScript("""
//            var abcd = function(name, callback) {
//                cruxClient.isCruxIDAvailable(name).then((res) => {
//                    callback(res);
//                    console.log(res);
//                })
//            }
//        """)
        
//        self.jsContext.evaluateScript("""
//            var resolveAfter2Seconds = function() {
//              console.log("starting slow promise");
//              return new Promise(resolve => {
//                setTimeout(function() {
//                  resolve("slow");
//                  console.log("slow promise is done");
//                }, 200000);
//              });
//            };
//        """)
//        let jsMethod = self.jsContext.objectForKeyedSubscript("resolveAfter2Seconds")
//        let res = jsMethod?.call(withArguments: [])
//        print(res)
//
        return "Tested executeAsync!"
    }
    
    public func executeAsync(callback_fn: @escaping (_ result: String) -> String) {
        let callback: @convention (block)(JSValue) -> () = { (content: JSValue) in
            print("Callback_fn result:")
//            content.
            print(callback_fn(content.toString()))
            print("Request result: \(content.toString())")
        }
        self.jsContext.setObject(callback, forKeyedSubscript: "testing" as NSString)
        let jsCallback = self.jsContext.objectForKeyedSubscript("testing")!
        self.jsContext.evaluateScript("""
            var abcd = function(name, callback) {
                cruxClient.isCruxIDAvailable(name).then((res) => {
                    callback(res);
                    console.log(res);
                })
            }
        """)
        let jsMethod = self.jsContext.objectForKeyedSubscript("abcd")
        _ = jsMethod?.call(withArguments: ["amy123", jsCallback])
    }
    
    public func tester(result: String) -> String {
        print(result)
        print("Thank you for testing tester. :)")
        return result
    }
//    public func getAssetMap() -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
//        context?.evaluateScript("var a = 12;")
//        let res = context?.evaluateScript("cruxClient.getAssetMap().then((res) => {consoleLog(JSON.stringify(res));}, (reason) => {consoleLog('reason failed: ');  consoleLog(JSON.stringify(reason));})")
//        print(res!)
//        return res?.toString()
//    }
//    public func registerCruxID(cruxID: String) -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
//        context?.evaluateScript("var a = 12;")
//        let res = context?.evaluateScript("cruxClient.registerCruxID(cruxID).then((res) => {consoleLog(JSON.stringify(res));}, (reason) => {consoleLog('reason failed: ');  consoleLog(JSON.stringify(reason));})")
//        print(res!)
//        return res?.toString()
//    }
//    public func resolveCurrencyAddressForCruxID(cruxID: String, walletCurrencySymbol: String) -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
//        context?.evaluateScript("var a = 12;")
//        let res = context?.evaluateScript("cruxClient.resolveCurrencyAddressForCruxID(cruxID, walletCurrencySymbol).then((res) => {consoleLog(JSON.stringify(res));}, (reason) => {consoleLog('reason failed: ');  consoleLog(JSON.stringify(reason));})")
//        print(res!)
//        return res?.toString()
//    }
//    public func getAddressMap() -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
//        context?.evaluateScript("var a = 12;")
//        let res = context?.evaluateScript("cruxClient.getAddressMap().then((res) => {consoleLog(JSON.stringify(res));}, (reason) => {consoleLog('reason failed: ');  consoleLog(JSON.stringify(reason));})")
//        print(res!)
//        return res?.toString()
//    }
//    public func putAddressMap(newAddressMap: String) -> String? {
//        guard context != nil else {
//            print("JSContext not found.")
//            return nil
//        }
//        context?.evaluateScript("var a = 12;")
//        let res = context?.evaluateScript("cruxClient.putAddressMap(newAddressMap).then((res) => {consoleLog(JSON.stringify(res));}, (reason) => {consoleLog('reason failed: ');  consoleLog(JSON.stringify(reason));})")
//        print(res!)
//        return res?.toString()
//    }
}
