import type { Request, Response } from 'express';
import { AppError } from '../utils/AppError.ts';
import { createSessionSchema, idParamSchema, updateSessionSchema } from '../validators/sessions.validator.ts';
import { sessionsService } from '../services/sessions.service.ts';
import { eventsService } from '../services/events.service.ts';

export async function getSessions(_req: Request, res: Response) {
  const sessions = await sessionsService.getAll();
  res.json({ data: sessions });
}

export async function getSession(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const session = await sessionsService.getById(id);
  if (!session) {
    throw new AppError('Session not found', 404);
  }
  res.json({ data: session });
}

export async function getSessionEvents(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const session = await sessionsService.getById(id);
  if (!session) {
    throw new AppError('Session not found', 404);
  }
  const events = await eventsService.getBySessionId(id);
  res.json({ data: events });
}

export async function createSession(req: Request, res: Response) {
  const data = createSessionSchema.parse(req.body);
  const session = await sessionsService.create(data);
  res.status(201).json({ data: session });
}

export async function updateSession(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const data = updateSessionSchema.parse(req.body);
  const session = await sessionsService.update(id, data);
  res.json({ data: session });
}

export async function deleteSession(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  await sessionsService.remove(id);
  res.status(204).send();
}
