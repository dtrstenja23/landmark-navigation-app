import { Router } from 'express';
import { createSession, deleteSession, getSession, getSessions, updateSession } from '../controllers/sessions.controller.ts';

const router = Router();

/**
 * @openapi
 * /api/sessions:
 *   get:
 *     summary: List all sessions
 *     tags: [Sessions]
 *     responses:
 *       200:
 *         description: List of sessions
 */
router.get('/', getSessions);

/**
 * @openapi
 * /api/sessions/{id}:
 *   get:
 *     summary: Get a session by id
 *     tags: [Sessions]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Session found
 *       404:
 *         description: Session not found
 */
router.get('/:id', getSession);

/**
 * @openapi
 * /api/sessions:
 *   post:
 *     summary: Create a session
 *     tags: [Sessions]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               user_id:
 *                 type: integer
 *               route_id:
 *                 type: integer
 *               started_at:
 *                 type: string
 *                 format: date-time
 *               ended_at:
 *                 type: string
 *                 format: date-time
 *               mode:
 *                 type: string
 *                 enum: [hybrid, landmark, classic]
 *     responses:
 *       201:
 *         description: Session created
 *       400:
 *         description: Validation failed
 */
router.post('/', createSession);

/**
 * @openapi
 * /api/sessions/{id}:
 *   patch:
 *     summary: Update a session
 *     tags: [Sessions]
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
 *               user_id:
 *                 type: integer
 *               route_id:
 *                 type: integer
 *               started_at:
 *                 type: string
 *                 format: date-time
 *               ended_at:
 *                 type: string
 *                 format: date-time
 *               mode:
 *                 type: string
 *                 enum: [hybrid, landmark, classic]
 *     responses:
 *       200:
 *         description: Session updated
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Session not found
 */
router.patch('/:id', updateSession);

/**
 * @openapi
 * /api/sessions/{id}:
 *   delete:
 *     summary: Delete a session
 *     tags: [Sessions]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Session deleted
 *       404:
 *         description: Session not found
 */
router.delete('/:id', deleteSession);

export default router;
