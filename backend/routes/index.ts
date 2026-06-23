import { Router } from 'express';
import landmarksRoutes from './landmarks.routes.ts';
import routesRoutes from './routes.routes.ts';
import usersRoutes from './users.routes.ts';

const router = Router();

router.use('/users', usersRoutes);
router.use('/landmarks', landmarksRoutes);
router.use('/routes', routesRoutes);

export default router;
