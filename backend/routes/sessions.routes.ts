import { Router } from 'express';
import { createSession, deleteSession, getSession, getSessionEvents, getSessions, updateSession } from '../controllers/sessions.controller.ts';

const router = Router();

router.get('/', getSessions);
router.get('/:id', getSession);
router.get('/:id/events', getSessionEvents);
router.post('/', createSession);
router.patch('/:id', updateSession);
router.delete('/:id', deleteSession);

export default router;
