import { z } from 'zod';

export const MODES = ['hybrid', 'landmark', 'classic'] as const;

export const createUserSchema = z.object({
  device_id: z.string().min(1).max(255),
  preferred_mode: z.enum(MODES).optional(),
  consent_research: z.boolean().optional(),
});

export const updateUserSchema = z
  .object({
    preferred_mode: z.enum(MODES).optional(),
    consent_research: z.boolean().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided',
  });

export const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export const upsertUserSchema = z.object({
  device_id: z.string().min(1).max(255),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type UpsertUserInput = z.infer<typeof upsertUserSchema>;
