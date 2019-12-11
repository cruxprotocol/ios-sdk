# CruxPay

[![Version](https://img.shields.io/cocoapods/v/CruxPay.svg?style=flat)](https://cocoapods.org/pods/CruxPay)
[![License](https://img.shields.io/cocoapods/l/CruxPay.svg?style=flat)](https://cocoapods.org/pods/CruxPay)
[![Platform](https://img.shields.io/cocoapods/p/CruxPay.svg?style=flat)](https://cocoapods.org/pods/CruxPay)

## Installation

CruxPay is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CruxPay'
```

## SDK Initialisation:
To initialize the sdk, you need to minimally pass following details:-
1. **walletClientName**
    - walletClientName is the key which identifies the wallet specific configurations stored in gaiaHub like 
        1. Subdomain Registrar Information
        2. BNS(BlockStack Name Service) Node
        3. Currency symbol map of your wallet
    - To help you get started, you can use `cruxdev` as the value which is already configured for our dev test users. It has 5 pre-registered crypto symbols for a fast start. You can contact us at [telegram](https://t.me/cruxpay_integration) channel for registration of your own walletClientName.
2. **privateKey (optional)**
    - Required to re-initialise the CruxClient with same user across different devices.
    - For clients using HD derivation paths, recommended to use the path (`m/889'/0/0'`) for CruxPay keypair node derivation with respect to account indices.
    
    Example below shows how to a cruxClient instance. These are the [SDK Operation](#sdk-operation) exposed.   
    ```swift
    import CruxPay
    
    let configBuilder = CruxClientInitConfig.Builder()
    configBuilder.setWalletClientName(walletClientName: "cruxdev")
    configBuilder.setPrivateKey(privateKey: "6bd397dc89272e71165a0e7d197b280c7a88ed5b1e44e1928c25455506f1968f") // (optional parameter)
    let cruxClient = CruxClient(configBuilder: configBuilder)
    ```
    That's it! now you can use the cruxClient object to perform operations defined in [SDK Operation](#sdk-operation).
    
## SDK Operation:

1. ##### isCruxIDAvailable(cruxIDSubdomain: String, onResponse: (Bool) -> (), onErrorResponse: (CruxClientError) -> ())
    - Description: Helps to check if a particular CruxID is available to be registered.
    - Params:
        - subdomain part of [CruxID](#cruxid)
        - onResponse callback function
        - onErrorResponse callback function
    ```swift
    cruxClient.isCruxIDAvailable(cruxIDSubdomain: "bob", onResponse: isCruxIDAvailableSuccess(cruxIDAvailable:), onErrorResponse: isCruxIDAvailableError(cruxError:))
    func isCruxIDAvailableSuccess(cruxIDAvailable: Bool) -> () {
        // Do something here
    }
    
    func isCruxIDAvailableError(cruxError: CruxClientError) -> () {
        // Do something here
    }
    ```

2. ##### registerCruxID(cruxIDSubdomain: String, onResponse: () -> (), onErrorResponse: (CruxClientError) -> ())
    - Description: Reserves/registers the cruxID for the user.
    - Params:
        - subdomain part of [CruxID](#cruxid)
        - onResponse callback function
        - onErrorResponse callback function
    ```swift
    cruxClient.registerCruxID(cruxIDSubdomain: "bob", onResponse: registerCruxIDSuccess, onErrorResponse: registerCruxIDError(cruxError:))
    func registerCruxIDSuccess() -> () {
        // Do something here
    }
    
    func registerCruxIDError(cruxError: CruxClientError) -> () {
        // Do something here
    }
    ```
    
3. ##### resolveCurrencyAddressForCruxID(fullCruxID: String, walletCurrencySymbol: String, onResponse: (Address) -> (), onErrorResponse: (CruxClientError) -> ())
    - Description: Helps to lookup a mapped address for a currency of any CruxID if its marked publically accessible.
    - Params:
        - complete [CruxID](#cruxid) of a user whose address you want to fetch
        - [walletCurrencySymbol](#walletcurrencysymbol) wallet symbol of currency whose address you want to fetch.
        - onResponse callback function
        - onErrorResponse callback function
    ```swift
    cruxClient.resolveCurrencyAddressForCruxID(fullCruxID: "bob@cruxdev.", walletCurrencySymbol: "btc", onResponse: resolveCurrencyAddressForCruxIDSuccess(address: ), onErrorResponse: resolveCurrencyAddressForCruxIDError(cruxError:))
    func resolveCurrencyAddressForCruxIDSuccess(address: Address) -> () {
        // Do something here
    }
    
    func resolveCurrencyAddressForCruxIDError(cruxError: CruxClientError) -> () {
        // Do something here
    }
    ```

4. ##### getAddressMap(onResponse: ([String: Address]) -> (), onErrorResponse: (CruxClientError) -> ())
    - Description: Get back the current publicly registered addresses.
    - Params:
        - onResponse callback function
        - onErrorResponse callback function
    ```swift
    cruxClient.getAddressMap(onResponse: getAddressMapSuccess(addressMap:), onErrorResponse: getAddressMapError(cruxError:))
    func getAddressMapSuccess(addressMap: [String: Address]) -> () {
        // Do something here
    }
    
    func getAddressMapError(cruxError: CruxClientError) -> () {
        // Do something here
    }
    ```
    
5. ##### putAddressMap(newAddressMap: [String: Address], onResponse: ([String: [String: Address]]) -> (), onErrorResponse: (CruxClientError) -> ())
    - Description: Helps to update 2 things:-
        - publish/change list of publicly accessible currency addresses.
        - change the value of addressHash and/or secIdentifier to another one.
    - Note: The addresses are now publicly linked and can be resolved.
    - Params:
        - newAddressMap has modified map has symbols and addresses a user wants to publically expose with CruxID.
        - onResponse callback function
        - onErrorResponse callback function
    ```swift
    
    let sampleAddressMap: [String: Address] = [
        "btc": Address(addressHash: "1F1tAaz5x1HUXrCNLbtMDqcw6o5GNn4xqX", secIdentifier: nil),
        "xrp": Address(addressHash: "rpfKAA2Ezqoq5wWo3XENdLYdZ8YGziz48h", secIdentifier: "123456")
    ]
    cruxClient.putAddressMap(newAddressMap: sampleAddressMap, onResponse: putAddressMapSuccess(putAddressMapResponse:), onErrorResponse: putAddressMapError(cruxError:))
    func putAddressMapSuccess(putAddressMapResponse: [String: [String: CruxPay.Address]]) -> () {
        // Do something here
    }
    
    func putAddressMapError(cruxError: CruxClientError) -> () {
        // Do something here
    }
    ```

6. ##### getCruxIDState(onResponse: (CruxIDState) -> (), onErrorResponse: (CruxClientError) -> ())
    - Description: Returns details of the current registered CruxID(if any) for this instance of the user wallet and its registration status
    - Params:
        - onResponse callback function
        - onErrorResponse callback function
    ```swift
    cruxClient.getCruxIDState(onResponse: getCruxIDStateSuccess(cruxState:), onErrorResponse: getCruxError(cruxError:))
    func getCruxIDStateSuccess(cruxState: CruxIDState) -> () {
        // Do something here
    }
    
    func getCruxError(cruxError: CruxClientError) -> () {
        // Do something here
    }
    ```
    
## SDK Object Definitions

1. ##### CruxIDRegistrationStatus
    - Example:
        ```
            CruxIDRegistrationStatus(status: "PENDING", statusDetail: "Your subdomain was registered in transaction")
        ```
    - Description: Defines the status in the registration process of the CruxID. It has 2 subcomponent.
        - status: 
            - Type: String
            - Description: which can have the following values [UNKNOWN, PENDING, REJECTED, DONE]
        - statusDetail:
            - Type: String
            - Description: which contains further details/reason about the status.

2. ##### CruxIDState
    
    - Example:
    ```
        let cruxIDRegistrationStatus = CruxIDRegistrationStatus(status: "PENDING", statusDetail: "Your subdomain was registered in transaction")
        CruxIDState(cruxID: "devtest@cruxdev.crux", registration_status: cruxIDRegistrationStatus)
    ```
    - Description: Return the current registered ID and its status.

3. ##### Address
    - Example:
    ```
       Address(addressHash: "rpfKAA2Ezqoq5wWo3XENdLYdZ8YGziz48h", secIdentifier: "123456")
    ```
    - Description: Address object. Here, **secIdentifier** is an optional field and sent as `nil` if not required by blockchain or blockchain supports yet you don’t want to add it.

## License

CruxPay is available under the GPL-3.0 license. See the LICENSE file for more info.
