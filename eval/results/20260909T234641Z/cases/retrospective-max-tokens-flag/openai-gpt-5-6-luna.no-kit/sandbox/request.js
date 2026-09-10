export async function call(model) {
  const body = { model };
  return fetch('https://api.example.com/v1/chat', {
    method: 'POST',
    body: JSON.stringify(body),
  });
}
