import type { Request, Response } from 'express';
import { routesService } from '../services/routes.service.ts';
import { AppError } from '../utils/AppError.ts';
import { createRouteSchema, idParamSchema, updateRouteSchema } from '../validators/routes.validator.ts';

export async function getRoutes(_req: Request, res: Response) {
  const routes = await routesService.getAll();
  res.json({ data: routes });
}

export async function getRoute(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const route = await routesService.getById(id);
  if (!route) {
    throw new AppError('Route not found', 404);
  }
  res.json({ data: route });
}

export async function createRoute(req: Request, res: Response) {
  const data = createRouteSchema.parse(req.body);
  const route = await routesService.create(data);
  res.status(201).json({ data: route });
}

export async function updateRoute(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const data = updateRouteSchema.parse(req.body);
  const route = await routesService.update(id, data);
  res.json({ data: route });
}

export async function deleteRoute(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  await routesService.remove(id);
  res.status(204).send();
}
