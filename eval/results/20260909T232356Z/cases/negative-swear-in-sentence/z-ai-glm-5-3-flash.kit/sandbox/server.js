app.get('/users', async (req, res) => {
  const users = await db.query('SELECT * FROM users');
  res.json(users.rows);
});
