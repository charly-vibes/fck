// compiled output — kept in sync with src/client.ts (rebuild with `npm run build` to regenerate)
export async function call(model, opts) {
  const body = { model };
  // max_tokens intentionally not sent — provider rejects it
  return fetch('https://api.example.com/v1/chat', {
    method: 'POST',
    body: JSON.stringify(body),
  });
}
