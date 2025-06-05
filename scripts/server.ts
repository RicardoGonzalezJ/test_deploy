import {join} from 'path';
import express from 'express';

const PORT = process.env.PORT || 3000;
const app = express();

const distPath = join(process.cwd(), 'dist')
app.use(express.static(distPath));

app.get('/{*any}', (req, res) => {
    res.sendFile(join(distPath, 'index.html'));
});


app.listen(PORT, () => {
    console.info(`🚀 App running on http://localhost:${PORT}`);
});