app.get('/users', async (req, res) => {
  const users = await db.query('SELECT * FORM users');
  res.json(users.rows);
});
