import { Router } from 'express';
import {
  createNavigationStep,
  deleteNavigationStep,
  getNavigationStep,
  getNavigationSteps,
  updateNavigationStep,
} from '../controllers/navigation-steps.controller.ts';

const router = Router();

router.get('/', getNavigationSteps);
router.get('/:id', getNavigationStep);
router.post('/', createNavigationStep);
router.patch('/:id', updateNavigationStep);
router.delete('/:id', deleteNavigationStep);

export default router;
