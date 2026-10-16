const express = require('express');

const app = express();
const PORT = 3000;

app.disable('x-powered-by');

app.get('/health', (req, res) => {
  res.json({
    success: true,
    app: 'Zingacc Learn AI Backend',
    status: 'running'
  });
});

app.listen(PORT, '127.0.0.1', () => {
  console.log(`Zingacc Backend running at http://127.0.0.1:${PORT}`);
});
