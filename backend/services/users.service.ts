import { prisma } from '../config/db.ts';
import type { CreateUserInput, UpdateUserInput, UpsertUserInput } from '../validators/users.validator.ts';

export const usersService = {
  getAll() {
    return prisma.users.findMany({ orderBy: { id: 'asc' } });
  },

  getById(id: number) {
    return prisma.users.findUnique({ where: { id } });
  },

  getByDeviceId(deviceId: string) {
    return prisma.users.findUnique({ where: { device_id: deviceId } });
  },

  create(data: CreateUserInput) {
    return prisma.users.create({ data });
  },

  update(id: number, data: UpdateUserInput) {
    return prisma.users.update({ where: { id }, data });
  },

  upsertByDeviceId(data: UpsertUserInput) {
    return prisma.users.upsert({
      where: { device_id: data.device_id },
      create: data,
      update: {},
    });
  },

  remove(id: number) {
    return prisma.users.delete({ where: { id } });
  },
};
