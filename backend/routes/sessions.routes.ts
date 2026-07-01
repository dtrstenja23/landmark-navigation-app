import { Router } from 'express';
import { createSession, deleteSession, getSession, getSessions, updateSession } from '../controllers/sessions.controller.ts';

const router = Router();

router.get('/', getSessions);
router.get('/:id', getSession);
router.post('/', createSession);
router.patch('/:id', updateSession);
router.delete('/:id', deleteSession);

export default router;
