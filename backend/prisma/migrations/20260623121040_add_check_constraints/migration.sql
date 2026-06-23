-- CheckConstraint
ALTER TABLE "users" ADD CONSTRAINT "users_preferred_mode_check" CHECK ("preferred_mode" IN ('hybrid', 'landmark', 'classic'));

-- CheckConstraint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_mode_check" CHECK ("mode" IN ('hybrid', 'landmark', 'classic'));

-- CheckConstraint
ALTER TABLE "landmarks" ADD CONSTRAINT "landmarks_type_check" CHECK ("type" IN ('building', 'intersection', 'shop', 'monument', 'transit_stop'));

-- CheckConstraint
ALTER TABLE "landmarks" ADD CONSTRAINT "landmarks_source_check" CHECK ("source" IN ('google_places', 'osm', 'manual'));

-- CheckConstraint
ALTER TABLE "events" ADD CONSTRAINT "events_event_type_check" CHECK ("event_type" IN ('missed_turn', 'landmark_shown', 'fallback_used', 'reroute_triggered'));
