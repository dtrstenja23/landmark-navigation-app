import { Router } from 'express';
import { createRoute, deleteRoute, getRoute, getRoutes, updateRoute } from '../controllers/routes.controller.ts';

const router = Router();

/**
 * @openapi
 * /api/routes:
 *   get:
 *     summary: List all routes
 *     tags: [Routes]
 *     responses:
 *       200:
 *         description: List of routes
 */
router.get('/', getRoutes);

/**
 * @openapi
 * /api/routes/{id}:
 *   get:
 *     summary: Get a route by id
 *     tags: [Routes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Route found
 *       404:
 *         description: Route not found
 */
router.get('/:id', getRoute);

/**
 * @openapi
 * /api/routes:
 *   post:
 *     summary: Create a route
 *     tags: [Routes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [origin_lat, origin_lng, dest_lat, dest_lng]
 *             properties:
 *               user_id:
 *                 type: integer
 *               origin_lat:
 *                 type: number
 *               origin_lng:
 *                 type: number
 *               dest_lat:
 *                 type: number
 *               dest_lng:
 *                 type: number
 *               polyline:
 *                 type: string
 *               total_distance_m:
 *                 type: integer
 *     responses:
 *       201:
 *         description: Route created
 *       400:
 *         description: Validation failed
 */
router.post('/', createRoute);

/**
 * @openapi
 * /api/routes/{id}:
 *   patch:
 *     summary: Update a route
 *     tags: [Routes]
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
 *               origin_lat:
 *                 type: number
 *               origin_lng:
 *                 type: number
 *               dest_lat:
 *                 type: number
 *               dest_lng:
 *                 type: number
 *               polyline:
 *                 type: string
 *               total_distance_m:
 *                 type: integer
 *     responses:
 *       200:
 *         description: Route updated
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Route not found
 */
router.patch('/:id', updateRoute);

/**
 * @openapi
 * /api/routes/{id}:
 *   delete:
 *     summary: Delete a route
 *     tags: [Routes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Route deleted
 *       404:
 *         description: Route not found
 */
router.delete('/:id', deleteRoute);

export default router;
