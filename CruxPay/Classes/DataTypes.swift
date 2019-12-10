//
//  DataTypes.swift
//  CruxPay
//
//  Created by Sanchay on 07/11/19.
//

import Foundation
import JavaScriptCore

public struct CruxIDRegistrationStatus: Codable {
    public let status: String
    public let statusDetail: String
}


public struct CruxClientInitConfig {
    public class Builder {
        var walletClientName: String?
        var privateKey: String?
        
        public init() {}
        public func setWalletClientName(walletClientName: String) -> Builder {
            self.walletClientName = walletClientName
            return self
        }
        public func setPrivateKey(privateKey: String) -> Builder {
            self.privateKey = privateKey
            return self
        }
        public func create() -> CruxClientInitConfig {
            return (CruxClientInitConfig(builder: self))
        }
    }
    
    private var builder: Builder;
    private var privateKey: String?;
    private var walletClientName: String;
    
    init(builder: Builder) {
        self.builder = builder;
        self.privateKey = builder.privateKey;
        self.walletClientName = builder.walletClientName!;
    }
    
    public func getCruxClientInitConfigString() -> String? {
        var cruxClientInitConfigDict = [String: String]()
        cruxClientInitConfigDict["walletClientName"] = self.walletClientName
        if self.privateKey != nil {
            cruxClientInitConfigDict["privateKey"] = self.privateKey
        }
        
        let cruxClientInitConfigJSONData = try! JSONSerialization.data(withJSONObject: cruxClientInitConfigDict, options: .prettyPrinted)
        let cruxClientInitConfigString = String(data: cruxClientInitConfigJSONData, encoding: String.Encoding.ascii)
        return cruxClientInitConfigString
    }
}

public struct CruxParams {
    public var args: [AnyObject]
    public init(_ args: AnyObject...) {
        self.args = args
    }
}

protocol CruxIDStateExports : JSExport {
    var cruxID:String? {get set}
    var status:CruxIDRegistrationStatus? {get set}
}

public struct CruxIDState: Codable {
    public var cruxID: String? = nil
    public var status: CruxIDRegistrationStatus? = nil
}

public struct CruxClientError: Error {
    public let message: String
    public let errorCode: String
    public let stack: String
    public let name: String
}

public struct Address: Codable {
    public init(addressHash: String, secIdentifier: String?) {
        self.addressHash = addressHash
        self.secIdentifier = secIdentifier
    }
    public let addressHash: String
    public let secIdentifier: String?
}
