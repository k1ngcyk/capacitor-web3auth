package com.kingcyk.capweb3auth

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
        
        if (web3auth == null) {
            web3auth = Web3Auth(
                Web3AuthOptions(
                    clientId = "BGiGcxrXAdtx-43HZ-gPdxlsNIbYe1BazcUfJCU6Z97nhG0T5_XMcj1H4mDBUOQiKBjjJfeDFO6ewJj-ZDvGUq8",
                    network = Network.SAPPHIRE_DEVNET,
                    redirectUrl = Uri.parse("co.datadance.app://auth")
                ),
                context = this.activity.applicationContext,
            )
        }

        var w3aLoginProvider: Provider
        var w3aLoginParams: LoginParams
        when (clientId) {
            "google" -> {
                w3aLoginProvider = Provider.GOOGLE
                w3aLoginParams = LoginParams(w3aLoginProvider)
            }
            "apple" -> {
                w3aLoginProvider = Provider.APPLE
                w3aLoginParams = LoginParams(w3aLoginProvider)
            }
            "x" -> {
                w3aLoginProvider = Provider.TWITTER
                w3aLoginParams = LoginParams(w3aLoginProvider)
            }
            "email" -> {
                w3aLoginProvider = Provider.EMAIL_PASSWORDLESS
                w3aLoginParams = LoginParams(w3aLoginProvider, extraLoginOptions = ExtraLoginOptions(
                    login_hint = network
                ))
            }
            else -> {
                call.reject("unknown clientId")
                return
            }
        }

        val loginCompletableFuture = web3auth?.login(w3aLoginParams)

        loginCompletableFuture?.whenComplete { loginResponse, error ->
            if (error == null) {
                val ret = JSObject()
                ret.put("result", loginResponse)
                call.resolve(ret)
            } else {
                call.reject(error.message)
            }
        }
    }
}
