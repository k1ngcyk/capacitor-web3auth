package com.kingcyk.capweb3auth

import android.content.Intent
import android.net.Uri
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.web3auth.core.Web3Auth
import com.web3auth.core.types.ExtraLoginOptions
import com.web3auth.core.types.LoginParams
import com.web3auth.core.types.Network
import com.web3auth.core.types.Provider
import com.web3auth.core.types.Web3AuthOptions
import kotlinx.coroutines.future.await
import kotlinx.coroutines.*

@CapacitorPlugin(name = "CapWeb3Auth")
class CapWeb3AuthPlugin : Plugin() {
    private val implementation = CapWeb3Auth()
    private var web3auth: Web3Auth? = null

    @PluginMethod
    fun echo(call: PluginCall) {
        val value = call.getString("value")

        val ret = JSObject()
        ret.put("value", implementation.echo(value))
        call.resolve(ret)
    }

    override fun handleOnNewIntent(intent: Intent?) {
        super.handleOnNewIntent(intent)
        web3auth?.setResultUrl(intent?.data)
    }

    @PluginMethod
    fun logout(call: PluginCall) {
        web3auth?.logout()
        call.resolve()
    }

    @PluginMethod
    fun login(call: PluginCall) {
        val clientId = call.getString("clientId")
        val network = call.getString("network")

        if (clientId == null) {
            call.reject("clientId is required")
            return
        }

        if (network == null) {
            call.reject("network is required")
            return
        }

        var w3aNetwork: Network? = null
        when (network) {
            "sapphire_devnet" -> w3aNetwork = Network.SAPPHIRE_DEVNET
            else -> {
                w3aNetwork = Network.SAPPHIRE_MAINNET
            }
        }

        val provider = call.getString("provider")
        val loginHint = call.getString("loginHint")
        val redirectUrl = call.getString("redirectUrl")

        val loginParams = when (provider) {
            "google" -> LoginParams(Provider.GOOGLE)
            "apple" -> LoginParams(Provider.APPLE)
            "x" -> LoginParams(Provider.TWITTER)
            "email" -> LoginParams(Provider.EMAIL_PASSWORDLESS, extraLoginOptions = ExtraLoginOptions(
                login_hint = loginHint
            ))
            else -> {
                call.reject("Unknown provider")
                return
            }
        }

        if (web3auth == null) {
            web3auth = Web3Auth(
                Web3AuthOptions(
                    clientId = clientId,
                    network = w3aNetwork,
                    redirectUrl = Uri.parse(redirectUrl)
                ),
                context = this@CapWeb3AuthPlugin.context
            )
            web3auth?.setResultUrl(this@CapWeb3AuthPlugin.activity.intent?.data)
            val initCompletableFuture = web3auth?.initialize()
            initCompletableFuture?.whenComplete { _, error ->
                if (error == null) {
                    println("web3auth init success")
                    val loginCompletableFuture = web3auth?.login(loginParams)
                    loginCompletableFuture?.whenComplete { result, error ->
                        if (error == null) {
                            val ret = JSObject()
                            val resultObj = JSObject()
                            val userInfo = JSObject()
                            userInfo.put("email", result?.userInfo?.email ?: "")
                            userInfo.put("name", result?.userInfo?.name ?: "")
                            userInfo.put("profileImage", result?.userInfo?.profileImage ?: "")
                            userInfo.put("verifier", result?.userInfo?.verifier ?: "")
                            userInfo.put("verifierId", result?.userInfo?.verifierId ?: "")
                            userInfo.put("typeOfLogin", result?.userInfo?.typeOfLogin ?: "")
                            userInfo.put("aggregateVerifier", result?.userInfo?.aggregateVerifier ?: "")
                            userInfo.put("dappShare", result?.userInfo?.dappShare ?: "")
                            userInfo.put("idToken", result?.userInfo?.idToken ?: "")
                            userInfo.put("oAuthIdToken", result?.userInfo?.oAuthIdToken ?: "")
                            userInfo.put("oAuthAccessToken", result?.userInfo?.oAuthAccessToken ?: "")
                            resultObj.put("userInfo", userInfo)
                            resultObj.put("privKey", result?.privKey ?: "")
                            resultObj.put("ed25519PrivKey", result?.ed25519PrivKey ?: "")
                            resultObj.put("sessionId", result?.sessionId ?: "")
                            ret.put("result", resultObj)
                            call.resolve(ret)
                        } else {
                            println("web3auth login fail")
                            call.reject(error.message)
                        }
                    }
                } else {
                    println("web3auth init fail")
                    call.reject(error.message)
                }
            }
        } else {
            val loginCompletableFuture = web3auth?.login(loginParams)
            loginCompletableFuture?.whenComplete { result, error ->
                if (error == null) {
                    println("web3auth login success")
                    val ret = JSObject()
                    val resultObj = JSObject()
                    val userInfo = JSObject()
                    userInfo.put("email", result?.userInfo?.email ?: "")
                    userInfo.put("name", result?.userInfo?.name ?: "")
                    userInfo.put("profileImage", result?.userInfo?.profileImage ?: "")
                    userInfo.put("verifier", result?.userInfo?.verifier ?: "")
                    userInfo.put("verifierId", result?.userInfo?.verifierId ?: "")
                    userInfo.put("typeOfLogin", result?.userInfo?.typeOfLogin ?: "")
                    userInfo.put("aggregateVerifier", result?.userInfo?.aggregateVerifier ?: "")
                    userInfo.put("dappShare", result?.userInfo?.dappShare ?: "")
                    userInfo.put("idToken", result?.userInfo?.idToken ?: "")
                    userInfo.put("oAuthIdToken", result?.userInfo?.oAuthIdToken ?: "")
                    userInfo.put("oAuthAccessToken", result?.userInfo?.oAuthAccessToken ?: "")
                    resultObj.put("userInfo", userInfo)
                    resultObj.put("privKey", result?.privKey ?: "")
                    resultObj.put("ed25519PrivKey", result?.ed25519PrivKey ?: "")
                    resultObj.put("sessionId", result?.sessionId ?: "")
                    ret.put("result", resultObj)
                    call.resolve(ret)
                } else {
                    println("web3auth login fail")
                    call.reject(error.message)
                }
            }
        }
    }
}
