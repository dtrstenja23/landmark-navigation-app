import {Router} from 'express';
import {createLandmark, deleteLandmark, getLandmark, getLandmarks, updateLandmark} from '../controllers/landmarks.controller.ts';

const router = Router();

/**
 * @openapi
 * /api/landmarks:
 *   get:
 *     summary: List all landmarks
 *     tags: [Landmarks]
 *     responses:
 *       200:
 *         description: List of landmarks
 */
router.get('/', getLandmarks);

/**
 * @openapi
 * /api/landmarks/{id}:
 *   get:
 *     summary: Get a landmark by id
 *     tags: [Landmarks]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Landmark found
 *       404:
 *         description: Landmark not found
 */
router.get('/:id', getLandmark);

/**
 * @openapi
 * /api/landmarks:
 *   post:
 *     summary: Create a landmark
 *     tags: [Landmarks]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, lat, lng]
 *             properties:
 *               name:
 *                 type: string
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *               type:
 *                 type: string
 *                 enum: [building, intersection, shop, monument, transit_stop]
 *               google_place_id:
 *                 type: string
 *               verified:
 *                 type: boolean
 *               source:
 *                 type: string
 *                 enum: [google_places, osm, manual]
 *     responses:
 *       201:
 *         description: Landmark created
 *       400:
 *         description: Validation failed
 *       409:
 *         description: google_place_id already exists
 */
router.post('/', createLandmark);

/**
 * @openapi
 * /api/landmarks/{id}:
 *   patch:
 *     summary: Update a landmark
 *     tags: [Landmarks]
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
 *               name:
 *                 type: string
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *               type:
 *                 type: string
 *                 enum: [building, intersection, shop, monument, transit_stop]
 *               google_place_id:
 *                 type: string
 *               verified:
 *                 type: boolean
 *               source:
 *                 type: string
 *                 enum: [google_places, osm, manual]
 *     responses:
 *       200:
 *         description: Landmark updated
 *       400:
 *         description: Validation failed
 *       404:
 *         description: Landmark not found
 */
router.patch('/:id', updateLandmark);

/**
 * @openapi
 * /api/landmarks/{id}:
 *   delete:
 *     summary: Delete a landmark
 *     tags: [Landmarks]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Landmark deleted
 *       404:
 *         description: Landmark not found
 */
router.delete('/:id', deleteLandmark);

export default router;
