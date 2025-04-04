import { registerPlugin } from '@capacitor/core';

import type { CapWeb3AuthPlugin } from './definitions';

const CapWeb3Auth = registerPlugin<CapWeb3AuthPlugin>('CapWeb3Auth', {
  web: () => import('./web').then((m) => new m.CapWeb3AuthWeb()),
});

export * from './definitions';
export { CapWeb3Auth };
