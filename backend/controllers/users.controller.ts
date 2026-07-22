import type { Request, Response } from 'express';
import { usersService } from '../services/users.service.ts';
import { AppError } from '../utils/AppError.ts';
import {createUserSchema, idParamSchema, updateUserSchema, upsertUserSchema} from '../validators/users.validator.ts';

export async function getUsers(_req: Request, res: Response) {
  const users = await usersService.getAll();
  res.json({ data: users });
}

export async function getUser(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const user = await usersService.getById(id);
  if (!user) {
    throw new AppError('User not found', 404);
  }
  res.json({ data: user });
}

export async function createUser(req: Request, res: Response) {
  const data = createUserSchema.parse(req.body);
  const user = await usersService.create(data);
  res.status(201).json({ data: user });
}

export async function upsertUser(req: Request, res: Response) {
  const data = upsertUserSchema.parse(req.body);
  const user = await usersService.upsertByDeviceId(data);
  res.json({ data: user });
}

export async function updateUser(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  const data = updateUserSchema.parse(req.body);
  const user = await usersService.update(id, data);
  res.json({ data: user });
}

export async function deleteUser(req: Request, res: Response) {
  const { id } = idParamSchema.parse(req.params);
  await usersService.remove(id);
  res.status(204).send();
}
