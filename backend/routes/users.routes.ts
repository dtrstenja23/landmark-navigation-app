import { Router } from 'express';
import {createUser, deleteUser, getUser, getUsers, updateUser, upsertUser} from '../controllers/users.controller.ts';

const router = Router();

router.get('/', getUsers);
router.get('/:id', getUser);
router.post('/', createUser);
router.post('/upsert', upsertUser);
router.patch('/:id', updateUser);
router.delete('/:id', deleteUser);

export default router;
