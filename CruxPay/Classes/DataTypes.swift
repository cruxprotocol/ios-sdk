//
//  DataTypes.swift
//  CruxPay
//
//  Created by Sanchay on 07/11/19.
//

import Foundation
import JavaScriptCore

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
        builder.privateKey = nil
    }
    
    public mutating func getCruxClientInitConfigString() -> String? {
        var cruxClientInitConfigDict = [String: String]()
        cruxClientInitConfigDict["walletClientName"] = self.walletClientName
        if self.privateKey != nil {
            cruxClientInitConfigDict["privateKey"] = self.privateKey
        }
        
        let cruxClientInitConfigJSONData = try! JSONSerialization.data(withJSONObject: cruxClientInitConfigDict, options: .prettyPrinted)
        let cruxClientInitConfigString = String(data: cruxClientInitConfigJSONData, encoding: String.Encoding.ascii)
        self.privateKey = nil
        return cruxClientInitConfigString
    }
}

public struct CruxIDRegistrationStatus: Codable {
    public let status: String
    public let statusDetail: String
}

public struct CruxIDState: Codable {
    public var cruxID: String?
    public var status: CruxIDRegistrationStatus
}

public struct GenericError: Codable {
    public var errorCode: Int
    public var errorEntity: String
    public var errorMessage: String
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

public struct CruxError: Error {
    public let message: String
}
