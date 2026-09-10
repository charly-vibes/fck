export async function call(model: string, opts: { maxTokens?: number }) {
  const body: Record<string, unknown> = { model };
  return fetch('https://api.example.com/v1/chat', {
    method: 'POST',
    body: JSON.stringify(body),
  });
}
