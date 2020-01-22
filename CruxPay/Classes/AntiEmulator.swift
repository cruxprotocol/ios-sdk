//
//  AntiEmulator.swift
//  CruxPay
//
//  Created by Umang Shukla on 20/01/20.
//

import Foundation

internal class AntiEmulator {

    static func isRunningInEmulator() -> Bool {

        return checkCompile() || checkRuntime();
    }

    private static func checkRuntime() -> Bool {

        return ProcessInfo().environment["SIMULATOR_DEVICE_NAME"] != nil
    }

    private static func checkCompile() -> Bool {

        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

}
