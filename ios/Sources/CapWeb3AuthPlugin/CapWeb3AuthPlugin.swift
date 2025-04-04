import Foundation
import Capacitor
import Web3Auth

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapWeb3AuthPlugin)
public class CapWeb3AuthPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CapWeb3AuthPlugin"
    public let jsName = "CapWeb3Auth"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = CapWeb3Auth()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    private var web3auth: Web3Auth? = nil

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

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
        let clientId = call.getString("clientId") ?? ""
        let network = call.getString("network") ?? ""
        let provider = call.getString("provider") ?? ""
        let loginHint = call.getString("loginHint") ?? ""
        let redirectUrl = call.getString("redirectUrl") ?? ""

        Task {
            do {
                if(web3auth != nil) {
                    try await web3auth?.logout();
                }
                if(web3auth == nil)
                {
                    web3auth = try! await Web3Auth(W3AInitParams(
                        clientId: clientId,
                        network: Network(rawValue: network) ?? .sapphire_devnet,
                        redirectUrl: redirectUrl,
                    ))
                }

                switch provider {
                    case "email":
                        let result = try await web3auth!.login(W3ALoginParams(loginProvider: .EMAIL_PASSWORDLESS, extraLoginOptions: .init(login_hint: loginHint)))
                    case "google":
                        let result = try await web3auth!.login(W3ALoginParams(loginProvider: .GOOGLE))
                    case "apple":
                        let result = try await web3auth!.login(W3ALoginParams(loginProvider: .APPLE))
                    default:
                        let result = try await web3auth!.login(W3ALoginParams(loginProvider: .GOOGLE))
                }

                let privateKey = web3auth!.getPrivkey()
                let web3AuthUserInfo = try! web3auth!.getUserInfo()
                
                let userInfo: [String: String] = [
                    "aggregateVerifier": web3AuthUserInfo.aggregateVerifier ?? "",
                    "email": web3AuthUserInfo.email ?? "",
                    "name": web3AuthUserInfo.name ?? "",
                    "profileImage": web3AuthUserInfo.profileImage ?? "",
                    "typeOfLogin": web3AuthUserInfo.typeOfLogin ?? "",
                    "verifier": web3AuthUserInfo.verifier ?? "",
                    "verifierId": web3AuthUserInfo.verifierId ?? "",
                    "dappShare": web3AuthUserInfo.dappShare ?? "",
                    "idToken": web3AuthUserInfo.idToken ?? "",
                    "oAuthIdToken": web3AuthUserInfo.oAuthIdToken ?? "",
                    "oAuthAccessToken": web3AuthUserInfo.oAuthAccessToken ?? ""
                ]
                
                let resultData: [String: Any] = [
                    "privKey": privateKey ?? "",
                    "sessionId": "",
                    "userInfo": userInfo
                ]
                
                try await web3auth?.logout();
                
                print("Logged out, returning")
                call.resolve(["result": resultData ])
                
            } catch {
                print("Error")
                call.reject("Error logging in through Web3", nil)
            }
        }
    }

}
