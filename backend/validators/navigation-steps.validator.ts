import { z } from 'zod';

export const createNavigationStepSchema = z.object({
  route_id: z.coerce.number().int().positive().optional(),
  step_index: z.number().int().nonnegative(),
  instruction_text: z.string().min(1),
  distance_m: z.number().int().positive().optional(),
  landmark_id: z.coerce.number().int().positive().optional(),
  is_landmark_based: z.boolean().optional(),
});

export const updateNavigationStepSchema = z
  .object({
    route_id: z.coerce.number().int().positive().optional(),
    step_index: z.number().int().nonnegative().optional(),
    instruction_text: z.string().min(1).optional(),
    distance_m: z.number().int().positive().optional(),
    landmark_id: z.coerce.number().int().positive().optional(),
    is_landmark_based: z.boolean().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided',
  });

export const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export type CreateNavigationStepInput = z.infer<typeof createNavigationStepSchema>;
export type UpdateNavigationStepInput = z.infer<typeof updateNavigationStepSchema>;
