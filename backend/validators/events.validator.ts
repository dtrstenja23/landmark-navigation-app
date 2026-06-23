import { z } from 'zod';

export const EVENT_TYPES = [
  'missed_turn',
  'landmark_shown',
  'fallback_used',
  'reroute_triggered',
] as const;

export const createEventSchema = z.object({
  session_id: z.coerce.number().int().positive().optional(),
  step_id: z.coerce.number().int().positive().optional(),
  event_type: z.enum(EVENT_TYPES).optional(),
  timestamp: z.coerce.date().optional(),
  reaction_time_ms: z.number().int().nonnegative().optional(),
  user_lat: z.number().optional(),
  user_lng: z.number().optional(),
  metadata: z.record(z.string(), z.any()).optional(),
});

export const updateEventSchema = z
  .object({
    session_id: z.coerce.number().int().positive().optional(),
    step_id: z.coerce.number().int().positive().optional(),
    event_type: z.enum(EVENT_TYPES).optional(),
    timestamp: z.coerce.date().optional(),
    reaction_time_ms: z.number().int().nonnegative().optional(),
    user_lat: z.number().optional(),
    user_lng: z.number().optional(),
    metadata: z.record(z.string(), z.any()).optional(),
  })
  .refine((data) => Object.keys(data).length > 0, {
    message: 'At least one field must be provided',
  });

export const idParamSchema = z.object({
  id: z.coerce.number().int().positive(),
});

export type CreateEventInput = z.infer<typeof createEventSchema>;
export type UpdateEventInput = z.infer<typeof updateEventSchema>;
