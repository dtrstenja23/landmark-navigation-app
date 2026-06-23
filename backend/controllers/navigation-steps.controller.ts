import type { Request, Response } from 'express';
import { navigationStepsService } from '../services/navigation-steps.service.ts';
import { AppError } from '../utils/AppError.ts';
import { createNavigationStepSchema, idParamSchema, updateNavigationStepSchema } from '../validators/navigation-steps.validator.ts';

export async function getNavigationSteps(_req: Request, res: Response) {
  const steps = await navigationStepsService.getAll();
  res.json({ data: steps });
}

export async function getNavigationStep(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const step = await navigationStepsService.getById(id);
  if (!step) {
    throw new AppError('Navigation step not found', 404);
  }
  res.json({ data: step });
}

export async function createNavigationStep(req: Request, res: Response) {
  const data = createNavigationStepSchema.parse(req.body);
  const step = await navigationStepsService.create(data);
  res.status(201).json({ data: step });
}

export async function updateNavigationStep(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const data = updateNavigationStepSchema.parse(req.body);
  const step = await navigationStepsService.update(id, data);
  res.json({ data: step });
}

export async function deleteNavigationStep(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  await navigationStepsService.remove(id);
  res.status(204).send();
}
