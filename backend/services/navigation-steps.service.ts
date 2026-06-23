import { prisma } from '../config/db.ts';
import type { CreateNavigationStepInput, UpdateNavigationStepInput } from '../validators/navigation-steps.validator.ts';

export const navigationStepsService = {
  getAll() {
    return prisma.navigation_steps.findMany({ orderBy: { id: 'asc' } });
  },

  getById(id: number) {
    return prisma.navigation_steps.findUnique({ where: { id } });
  },

  create(data: CreateNavigationStepInput) {
    return prisma.navigation_steps.create({ data });
  },

  update(id: number, data: UpdateNavigationStepInput) {
    return prisma.navigation_steps.update({ where: { id }, data });
  },

  remove(id: number) {
    return prisma.navigation_steps.delete({ where: { id } });
  },
};
