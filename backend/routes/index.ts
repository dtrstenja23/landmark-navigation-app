import { Router } from 'express';
import landmarksRoutes from './landmarks.routes.ts';
import usersRoutes from './users.routes.ts';

const router = Router();

router.use('/users', usersRoutes);
router.use('/landmarks', landmarksRoutes);

export default router;
