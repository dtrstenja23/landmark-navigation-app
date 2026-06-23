import { z } from 'zod';

export const createRouteSchema = z.object({
  user_id: z.coerce.number().int().positive().optional(),
  origin_lat: z.number(),
  origin_lng: z.number(),
  dest_lat: z.number(),
  dest_lng: z.number(),
  polyline: z.string().min(1).optional(),
  total_distance_m: z.number().int().positive().optional(),
});

export const updateRouteSchema = z
  .object({
    user_id: z.coerce.number().int().positive().optional(),
    origin_lat: z.number().optional(),
    origin_lng: z.number().optional(),
    dest_lat: z.number().optional(),
    dest_lng: z.number().optional(),
    polyline: z.string().min(1).optional(),
    total_distance_m: z.number().int().positive().optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided',
  });

export const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export type CreateRouteInput = z.infer<typeof createRouteSchema>;
export type UpdateRouteInput = z.infer<typeof updateRouteSchema>;
