import type { Request, Response } from 'express';
import {landmarksService} from '../services/landmarks.service.ts';
import { AppError } from '../utils/AppError.ts';
import {createLandmarkSchema, idParamSchema, updateLandmarkSchema} from '../validators/landmarks.validator.ts';

export async function getLandmarks(_req: Request, res: Response) {
    const landmarks = await landmarksService.getAll();
    res.json({ data: landmarks });
}

export async function getLandmark(req: Request, res: Response) {
    const { id } = idParamSchema.parse(req.params);
    const landmark = await landmarksService.getById(id);
    if (!landmark) {
        throw new AppError('Landmark not found', 404);
    }
    res.json({ data: landmark });
}

export async function createLandmark(req: Request, res: Response) {
    const data = createLandmarkSchema.parse(req.body);
    const landmark = await landmarksService.create(data);
    res.status(201).json({ data: landmark });
}

export async function updateLandmark(req: Request, res: Response) {
    const { id } = idParamSchema.parse(req.params);
    const data = updateLandmarkSchema.parse(req.body);
    const landmark = await landmarksService.update(id, data);
    res.json({ data: landmark });
}

export async function deleteLandmark(req: Request, res: Response) {
    const { id } = idParamSchema.parse(req.params);
    await landmarksService.remove(id);
    res.status(204).send();
}