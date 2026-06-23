import { Router } from 'express';
import landmarksRoutes from './landmarks.routes.ts';
import navigationStepsRoutes from './navigation-steps.routes.ts';
import routesRoutes from './routes.routes.ts';
import usersRoutes from './users.routes.ts';

const router = Router();

router.use('/users', usersRoutes);
router.use('/landmarks', landmarksRoutes);
router.use('/routes', routesRoutes);
router.use('/navigation-steps', navigationStepsRoutes);

export default router;
