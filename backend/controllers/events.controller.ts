import type { Request, Response } from 'express';
import { eventsService } from '../services/events.service.ts';
import { AppError } from '../utils/AppError.ts';
import { createEventSchema, idParamSchema, updateEventSchema } from '../validators/events.validator.ts';

export async function getEvents(_req: Request, res: Response) {
  const events = await eventsService.getAll();
  res.json({ data: events });
}

export async function getEvent(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const event = await eventsService.getById(id);
  if (!event) {
    throw new AppError('Event not found', 404);
  }
  res.json({ data: event });
}

export async function createEvent(req: Request, res: Response) {
  const data = createEventSchema.parse(req.body);
  const event = await eventsService.create(data);
  res.status(201).json({ data: event });
}

export async function updateEvent(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const data = updateEventSchema.parse(req.body);
  const event = await eventsService.update(id, data);
  res.json({ data: event });
}

export async function deleteEvent(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  await eventsService.remove(id);
  res.status(204).send();
}
