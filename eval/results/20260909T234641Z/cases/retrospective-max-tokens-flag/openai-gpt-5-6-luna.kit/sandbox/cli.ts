import { call } from './client.js';
export async function main() {
  await call('test-model', { maxTokens: 4096 });
}
