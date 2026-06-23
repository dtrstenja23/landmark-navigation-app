import express from 'express';
import swaggerUi from 'swagger-ui-express';
import { env } from './config/env.ts';
import { prisma } from './config/db.ts';
import { swaggerSpec } from './config/swagger.ts';
import { errorHandler } from './middleware/errorHandler.ts';
import { notFound } from './middleware/notFound.ts';
import routes from './routes/index.ts';

const app = express();

app.use(express.json());

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use('/api', routes);

app.use(notFound);
app.use(errorHandler);

const server = app.listen(env.PORT, () => {
  console.log(`Server running on http://localhost:${env.PORT}`);
});

async function shutdown(signal: string) {
  console.log(`${signal} received, shutting down`);
  await prisma.$disconnect();
  server.close(() => process.exit(0));
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));