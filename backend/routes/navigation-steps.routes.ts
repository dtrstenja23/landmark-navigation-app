import { Router } from 'express';
import {
  createNavigationStep,
  deleteNavigationStep,
  getNavigationStep,
  getNavigationSteps,
  updateNavigationStep,
} from '../controllers/navigation-steps.controller.ts';

const router = Router();

/**
 * @openapi
 * /api/navigation-steps:
 *   get:
 *     summary: List all navigation steps
 *     tags: [NavigationSteps]
 *     responses:
 *       200:
 *         description: List of navigation steps
 */
router.get('/', getNavigationSteps);

/**
 * @openapi
 * /api/navigation-steps/{id}:
 *   get:
 *     summary: Get a navigation step by id
 *     tags: [NavigationSteps]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Navigation step found
 *       404:
 *         description: Navigation step not found
 */
router.get('/:id', getNavigationStep);

/**
 * @openapi
 * /api/navigation-steps:
 *   post:
 *     summary: Create a navigation step
 *     tags: [NavigationSteps]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [step_index, instruction_text]
 *             properties:
 *               route_id:
 *                 type: integer
 *               step_index:
 *                 type: integer
 *               instruction_text:
 *                 type: string
 *               distance_m:
 *                 type: integer
 *               landmark_id:
 *                 type: integer
 *               is_landmark_based:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Navigation step created
 *       400:
 *         description: Validation failed
 */
router.post('/', createNavigationStep);

/**
 * @openapi
 * /api/navigation-steps/{id}:
 *   patch:
 *     summary: Update a navigation step
 *     tags: [NavigationSteps]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               route_id:
 *                 type: integer
 *               step_index:
 *                 type: integer
 *               instruction_text:
 *                 type: string
 *               distance_m:
 *                 type: integer
 *               landmark_id:
 *                 type: integer
 *               is_landmark_based:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Navigation step updated
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Navigation step not found
 */
router.patch('/:id', updateNavigationStep);

/**
 * @openapi
 * /api/navigation-steps/{id}:
 *   delete:
 *     summary: Delete a navigation step
 *     tags: [NavigationSteps]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Navigation step deleted
 *       404:
 *         description: Navigation step not found
 */
router.delete('/:id', deleteNavigationStep);

export default router;
