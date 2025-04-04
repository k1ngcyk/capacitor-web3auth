export interface CapWeb3AuthPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
