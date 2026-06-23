import { z } from 'zod';
import { MODES } from './users.validator.ts';

export const createSessionSchema = z.object({
  user_id: z.coerce.number().int().positive().optional(),
  route_id: z.coerce.number().int().positive().optional(),
  started_at: z.coerce.date().optional(),
  ended_at: z.coerce.date().optional(),
  mode: z.enum(MODES).optional(),
});

export const updateSessionSchema = z
  .object({
    user_id: z.coerce.number().int().positive().optional(),
    route_id: z.coerce.number().int().positive().optional(),
    started_at: z.coerce.date().optional(),
    ended_at: z.coerce.date().optional(),
    mode: z.enum(MODES).optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided',
  });

export const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export type CreateSessionInput = z.infer<typeof createSessionSchema>;
export type UpdateSessionInput = z.infer<typeof updateSessionSchema>;
