import { Router } from 'express';
import eventsRoutes from './events.routes.ts';
import landmarksRoutes from './landmarks.routes.ts';
import navigationStepsRoutes from './navigation-steps.routes.ts';
import routesRoutes from './routes.routes.ts';
import sessionsRoutes from './sessions.routes.ts';
import usersRoutes from './users.routes.ts';

const router = Router();

router.use('/users', usersRoutes);
router.use('/landmarks', landmarksRoutes);
router.use('/routes', routesRoutes);
router.use('/navigation-steps', navigationStepsRoutes);
router.use('/sessions', sessionsRoutes);
router.use('/events', eventsRoutes);

export default router;
