import { prisma } from '../config/db.ts';
import type { CreateEventInput, UpdateEventInput } from '../validators/events.validator.ts';

export const eventsService = {
  getAll() {
    return prisma.events.findMany({ orderBy: { id: 'asc' } });
  },

  getById(id: number) {
    return prisma.events.findUnique({ where: { id } });
  },

  create(data: CreateEventInput) {
    return prisma.events.create({ data });
  },

  update(id: number, data: UpdateEventInput) {
    return prisma.events.update({ where: { id }, data });
  },

  remove(id: number) {
    return prisma.events.delete({ where: { id } });
  },
};
