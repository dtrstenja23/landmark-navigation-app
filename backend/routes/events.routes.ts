import { Router } from 'express';
import { createEvent, deleteEvent, getEvent, getEvents, updateEvent } from '../controllers/events.controller.ts';

const router = Router();

/**
 * @openapi
 * /api/events:
 *   get:
 *     summary: List all events
 *     tags: [Events]
 *     responses:
 *       200:
 *         description: List of events
 */
router.get('/', getEvents);

/**
 * @openapi
 * /api/events/{id}:
 *   get:
 *     summary: Get an event by id
 *     tags: [Events]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Event found
 *       404:
 *         description: Event not found
 */
router.get('/:id', getEvent);

/**
 * @openapi
 * /api/events:
 *   post:
 *     summary: Create an event
 *     tags: [Events]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               session_id:
 *                 type: integer
 *               step_id:
 *                 type: integer
 *               event_type:
 *                 type: string
 *                 enum: [missed_turn, landmark_shown, fallback_used, reroute_triggered]
 *               timestamp:
 *                 type: string
 *                 format: date-time
 *               reaction_time_ms:
 *                 type: integer
 *               user_lat:
 *                 type: number
 *               user_lng:
 *                 type: number
 *               metadata:
 *                 type: object
 *     responses:
 *       201:
 *         description: Event created
 *       400:
 *         description: Validation failed
 */
router.post('/', createEvent);

/**
 * @openapi
 * /api/events/{id}:
 *   patch:
 *     summary: Update an event
 *     tags: [Events]
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
 *               session_id:
 *                 type: integer
 *               step_id:
 *                 type: integer
 *               event_type:
 *                 type: string
 *                 enum: [missed_turn, landmark_shown, fallback_used, reroute_triggered]
 *               timestamp:
 *                 type: string
 *                 format: date-time
 *               reaction_time_ms:
 *                 type: integer
 *               user_lat:
 *                 type: number
 *               user_lng:
 *                 type: number
 *               metadata:
 *                 type: object
 *     responses:
 *       200:
 *         description: Event updated
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Event not found
 */
router.patch('/:id', updateEvent);

/**
 * @openapi
 * /api/events/{id}:
 *   delete:
 *     summary: Delete an event
 *     tags: [Events]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Event deleted
 *       404:
 *         description: Event not found
 */
router.delete('/:id', deleteEvent);

export default router;
