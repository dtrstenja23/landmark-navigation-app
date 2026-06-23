import { prisma } from '../config/db.ts';
import type { CreateLandmarkInput, UpdateLandmarkInput } from '../validators/landmarks.validator.ts';

export const landmarksService = {
    getAll(){
        return prisma.landmarks.findMany({ orderBy: { id: 'asc' } });
    },

    getById(id: number){
        return prisma.landmarks.findUnique({ where: { id } });
    },

    create(data: CreateLandmarkInput){
        return prisma.landmarks.create({ data });
    },

    update(id: number, data: UpdateLandmarkInput){
        return prisma.landmarks.update({ where: { id }, data });
    },

    remove(id: number){
        return prisma.landmarks.delete({ where: { id } });
    }
};