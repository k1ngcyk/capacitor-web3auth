export interface CapWeb3AuthPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  login(options: W3ALoginParams): Promise<{
    result: W3ALoginResponse;
  }>;
  logout(): Promise<void>;
}

export declare type W3ALoginResponse = {
  privKey?: string;
  ed25519PrivateKey?: string;
  userInfo?: W3AUserInfo;
  sessionId?: string;
};

export declare type W3AUserInfo = {
  aggregateVerifier?: string;
  email?: string;
  name?: string;
  profileImage?: string;
  typeOfLogin?: string;
  verifier?: string;
  verifierId?: string;
  dappShare?: string;
  idToken?: string;
  oAuthIdToken?: string;
  oAuthAccessToken?: string;
};

export declare type W3ALoginParams = {
  clientId: string;
  network: string;
  provider: string;
  loginHint?: string;
  redirectUrl?: string;
};