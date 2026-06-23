import { Router } from 'express';
import {createUser, deleteUser, getUser, getUsers, updateUser} from '../controllers/users.controller.ts';

const router = Router();

/**
 * @openapi
 * /api/users:
 *   get:
 *     summary: List all users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: List of users
 */
router.get('/', getUsers);

/**
 * @openapi
 * /api/users/{id}:
 *   get:
 *     summary: Get a user by id
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: User found
 *       404:
 *         description: User not found
 */
router.get('/:id', getUser);

/**
 * @openapi
 * /api/users:
 *   post:
 *     summary: Create a user
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [device_id]
 *             properties:
 *               device_id:
 *                 type: string
 *               preferred_mode:
 *                 type: string
 *                 enum: [hybrid, landmark, classic]
 *               consent_research:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: User created
 *       400:
 *         description: Validation failed
 *       409:
 *         description: device_id already exists
 */
router.post('/', createUser);

/**
 * @openapi
 * /api/users/{id}:
 *   patch:
 *     summary: Update a user
 *     tags: [Users]
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
 *               preferred_mode:
 *                 type: string
 *                 enum: [hybrid, landmark, classic]
 *               consent_research:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: User updated
 *       400:
 *         description: Validation failed
 *       404:
 *         description: User not found
 */
router.patch('/:id', updateUser);

/**
 * @openapi
 * /api/users/{id}:
 *   delete:
 *     summary: Delete a user
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: User deleted
 *       404:
 *         description: User not found
 */
router.delete('/:id', deleteUser);

export default router;
