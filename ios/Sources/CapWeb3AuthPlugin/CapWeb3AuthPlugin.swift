import Foundation
import Capacitor
import Web3Auth

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapWeb3AuthPlugin)
public class CapWeb3AuthPlugin: CAPPlugin, CAPBridgedPlugin {
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "login", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "logout", returnType: CAPPluginReturnPromise),
    ]

    public let identifier = "CapWeb3AuthPlugin"
    public let jsName = "CapWeb3Auth"
    private let implementation = CapWeb3Auth()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    private var web3auth: Web3Auth? = nil
    
    @objc func logout(_ call: CAPPluginCall) {
        Task {
            do {
                try await web3auth?.logout();
            } catch {
                call.reject("Error logging out through Web3", nil)
            }
        } 
        call.resolve()
    }

    @objc func login(_ call: CAPPluginCall) {
        guard let clientId = call.getString("clientId") else {
            call.reject("clientId is required")
            return
        }

        guard let network = call.getString("network") else {
            call.reject("network is required")
            return
        }

        guard let provider = call.getString("provider") else {
            call.reject("provider is required")
            return
        }

        let loginHint = call.getString("loginHint")
        let redirectUrl = call.getString("redirectUrl")

        var w3aNetwork: Network
        switch network.lowercased() {
        case "sapphire_devnet":
            w3aNetwork = .sapphire_devnet
        default:
            w3aNetwork = .sapphire_mainnet
        }
        
        Task {
            do {
                // Initialize Web3Auth if not already initialized
                if web3auth == nil {
                    print("Initializing Web3Auth...")
                    web3auth = try! await Web3Auth(W3AInitParams(
                        clientId: clientId,
                        network: w3aNetwork,
                        redirectUrl: redirectUrl ?? ""
                    ))
                    print("Web3Auth initialized successfully")
                }
                
                guard let web3auth = web3auth else {
                    call.reject("Failed to initialize Web3Auth")
                    return
                }
                
                var loginParams: W3ALoginParams
                
                switch provider.lowercased() {
                case "google":
                    print("Attempting Google login")
                    loginParams = W3ALoginParams(loginProvider: .GOOGLE)
                case "apple":
                    print("Attempting Apple login")
                    loginParams = W3ALoginParams(loginProvider: .APPLE)
                case "x":
                    print("Attempting Apple login")
                    loginParams = W3ALoginParams(loginProvider: .TWITTER, redirectUrl: redirectUrl ?? "")
                case "email":
                    if let email = loginHint {
                        print("Attempting Email login with: \(email)")
                        loginParams = W3ALoginParams(
                            loginProvider: .EMAIL_PASSWORDLESS,
                            extraLoginOptions: .init(login_hint: email)
                        )
                    } else {
                        call.reject("loginHint is required for email login")
                        return
                    }
                default:
                    call.reject("Unsupported login provider: \(provider)")
                    return
                }
                
                print("Executing login with params...")
                let result = try await web3auth.login(loginParams)
                print("Login successful")
                
                // Get user info
                let userInfo = try web3auth.getUserInfo()
                let privateKey = web3auth.getPrivkey()
                
                let userInfoDict: [String: String] = [
                    "aggregateVerifier": userInfo.aggregateVerifier ?? "",
                    "email": userInfo.email ?? "",
                    "name": userInfo.name ?? "",
                    "profileImage": userInfo.profileImage ?? "",
                    "typeOfLogin": userInfo.typeOfLogin ?? "",
                    "verifier": userInfo.verifier ?? "",
                    "verifierId": userInfo.verifierId ?? "",
                    "dappShare": userInfo.dappShare ?? "",
                    "idToken": userInfo.idToken ?? "",
                    "oAuthIdToken": userInfo.oAuthIdToken ?? "",
                    "oAuthAccessToken": userInfo.oAuthAccessToken ?? ""
                ]
                
                let resultData: [String: Any] = [
                    "ed25519PrivKey": "",
                    "privKey": privateKey ?? "",
                    "sessionId": "",
                    "userInfo": userInfoDict
                ]
                
                call.resolve(["result": resultData])
                
            } catch {
                print("Login failed with error: \(error.localizedDescription)")
                call.reject("Login failed: \(error.localizedDescription)")
            }
        }
    }

}
