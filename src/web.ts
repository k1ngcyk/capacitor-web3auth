import { WebPlugin } from '@capacitor/core';

import type { CapWeb3AuthPlugin } from './definitions';

export class CapWeb3AuthWeb extends WebPlugin implements CapWeb3AuthPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async login(options: {
    clientId: string;
    network: string;
    provider: string;
    loginHint?: string;
  }): Promise<{ result: any }> {
    console.log('LOGIN', options);
    return { result: {} };
  }

  async logout(): Promise<void> {
    console.log('LOGOUT');
  }
}
