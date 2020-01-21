//
//  SafetyChecks.swift
//  CruxPay
//
//  Created by Umang Shukla on 17/01/20.
//

import Foundation
import os

public class SafetyChecks {
    
    public init() {} // Constuctor
    
    public func checkSafety() -> Bool {
        let isUnsafe:Bool = _checkSafety();
        if (isUnsafe) {
            os_log("sdk informed unsafe env", log: OSLog.default, type: .debug);
        }
        if (isReleaseVersion()) {
            return isUnsafe;
            // System.exit(0);
        }
        return false;
    }
    
    private func isReleaseVersion() -> Bool {
        // TODO: use .xcconfig to find is release version or not
        #if DEBUG
            os_log("DEBUG version", log: OSLog.default, type: .debug);
            return false;
        #else
            os_log("is RELEASE version", log: OSLog.default, type: .debug);
            return true;
        #endif
    }

    private func _checkSafety() -> Bool {

        let jailbreakStatus = AntiJailbreak.isJailbrokenWithFailMessage();
        if (jailbreakStatus.jailbroken) {
            os_log("Jailbreak: %s", log: OSLog.default, type: .debug, jailbreakStatus.failMessage)
        }
        
        let isDebugged = AntiDebug.isDebugged();
        if (isDebugged) {
            os_log("Debugged true", log: OSLog.default, type: .debug)
        }
        
        let isRunningInEmulator = AntiEmulator.isRunningInEmulator();
        if (isRunningInEmulator) {
            os_log("Emulator true", log: OSLog.default, type: .debug)
        }
        
        let isReverseEngineered = AntiTamper.isReverseEngineered();
        if (isReverseEngineered) {
            os_log("Reversed true", log: OSLog.default, type: .debug)
        }
        
        let msg = """
        Jailbreak: \(jailbreakStatus.failMessage),
        Run in emulator?: \(isRunningInEmulator)
        Debugged?: \(isDebugged)
        Reversed?: \(isReverseEngineered)
        """
        os_log("checkSafety %s", log: OSLog.default, type: .debug, msg);

        return jailbreakStatus.jailbroken || isDebugged || isRunningInEmulator || isReverseEngineered;

    }
}
