import { Router } from 'express';
import usersRoutes from './users.routes.ts';

const router = Router();

router.use('/users', usersRoutes);

export default router;
