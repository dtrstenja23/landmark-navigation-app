import { z } from 'zod';

export const LANDMARK_TYPES = [
  'building',
  'intersection',
  'shop',
  'monument',
  'transit_stop',
] as const;

export const LANDMARK_SOURCES = ['google_places', 'osm', 'manual'] as const;

export const createLandmarkSchema = z.object({
  name: z.string().min(1).max(255),
  lat: z.number(),
  lng: z.number(),
  type: z.enum(LANDMARK_TYPES).optional(),
  google_place_id: z.string().min(1).max(255).optional(),
  verified: z.boolean().optional(),
  source: z.enum(LANDMARK_SOURCES).optional(),
});

export const updateLandmarkSchema = z
  .object({
    name: z.string().min(1).max(255).optional(),
    lat: z.number().optional(),
    lng: z.number().optional(),
    type: z.enum(LANDMARK_TYPES).optional(),
    google_place_id: z.string().min(1).max(255).optional(),
    verified: z.boolean().optional(),
    source: z.enum(LANDMARK_SOURCES).optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided',
  });

export const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export type CreateLandmarkInput = z.infer<typeof createLandmarkSchema>;
export type UpdateLandmarkInput = z.infer<typeof updateLandmarkSchema>;
