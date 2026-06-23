import { prisma } from '../config/db.ts';
import type { CreateSessionInput, UpdateSessionInput } from '../validators/sessions.validator.ts';

export const sessionsService = {
  getAll() {
    return prisma.sessions.findMany({ orderBy: { id: 'asc' } });
  },

  getById(id: number) {
    return prisma.sessions.findUnique({ where: { id } });
  },

  create(data: CreateSessionInput) {
    return prisma.sessions.create({ data });
  },

  update(id: number, data: UpdateSessionInput) {
    return prisma.sessions.update({ where: { id }, data });
  },

  remove(id: number) {
    return prisma.sessions.delete({ where: { id } });
  },
};