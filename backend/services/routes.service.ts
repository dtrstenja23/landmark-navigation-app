import { prisma } from '../config/db.ts';
import type { CreateRouteInput, UpdateRouteInput } from '../validators/routes.validator.ts';

export const routesService = {
  getAll() {
    return prisma.routes.findMany({ orderBy: { id: 'asc' } });
  },

  getById(id: number) {
    return prisma.routes.findUnique({ where: { id } });
  },

  create(data: CreateRouteInput) {
    return prisma.routes.create({ data });
  },

  update(id: number, data: UpdateRouteInput) {
    return prisma.routes.update({ where: { id }, data });
  },

  remove(id: number) {
    return prisma.routes.delete({ where: { id } });
  },
};
