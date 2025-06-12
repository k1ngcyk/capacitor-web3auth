# capacitor-web3auth

capacitor web3auth plugin

## Install

```bash
npm install capacitor-web3auth
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`login(...)`](#login)
* [`logout()`](#logout)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### login(...)

```typescript
login(options: W3ALoginParams) => Promise<{ result: W3ALoginResponse; }>
```

| Param         | Type                                                      |
| ------------- | --------------------------------------------------------- |
| **`options`** | <code><a href="#w3aloginparams">W3ALoginParams</a></code> |

**Returns:** <code>Promise&lt;{ result: <a href="#w3aloginresponse">W3ALoginResponse</a>; }&gt;</code>

--------------------


### logout()

```typescript
logout() => Promise<void>
```

--------------------


### Type Aliases


#### W3ALoginResponse

<code>{ privKey?: string; ed25519PrivateKey?: string; userInfo?: <a href="#w3auserinfo">W3AUserInfo</a>; sessionId?: string; }</code>


#### W3AUserInfo

<code>{ aggregateVerifier?: string; email?: string; name?: string; profileImage?: string; typeOfLogin?: string; verifier?: string; verifierId?: string; dappShare?: string; idToken?: string; oAuthIdToken?: string; oAuthAccessToken?: string; }</code>


#### W3ALoginParams

<code>{ clientId: string; network: string; provider: string; loginHint?: string; redirectUrl?: string; }</code>

</docgen-api>
