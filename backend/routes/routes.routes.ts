import { Router } from 'express';
import { createRoute, deleteRoute, generateRoute, getRoute, getRoutes, updateRoute } from '../controllers/routes.controller.ts';

const router = Router();

router.get('/', getRoutes);
router.get('/:id', getRoute);
router.post('/', createRoute);
router.post('/generate',generateRoute);
router.patch('/:id', updateRoute);
router.delete('/:id', deleteRoute);

export default router;
