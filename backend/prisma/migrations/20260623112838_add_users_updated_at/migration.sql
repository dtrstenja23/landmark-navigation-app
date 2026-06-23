-- CreateTable
CREATE TABLE "events" (
    "id" SERIAL NOT NULL,
    "session_id" INTEGER,
    "step_id" INTEGER,
    "event_type" VARCHAR(50),
    "timestamp" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "reaction_time_ms" INTEGER,
    "user_lat" DOUBLE PRECISION,
    "user_lng" DOUBLE PRECISION,
    "metadata" JSONB,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "landmarks" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "type" VARCHAR(50),
    "google_place_id" VARCHAR(255),
    "verified" BOOLEAN DEFAULT false,
    "source" VARCHAR(20) DEFAULT 'google_places',

    CONSTRAINT "landmarks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "navigation_steps" (
    "id" SERIAL NOT NULL,
    "route_id" INTEGER,
    "step_index" INTEGER NOT NULL,
    "instruction_text" TEXT NOT NULL,
    "distance_m" INTEGER,
    "landmark_id" INTEGER,
    "is_landmark_based" BOOLEAN DEFAULT false,

    CONSTRAINT "navigation_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "routes" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "origin_lat" DOUBLE PRECISION NOT NULL,
    "origin_lng" DOUBLE PRECISION NOT NULL,
    "dest_lat" DOUBLE PRECISION NOT NULL,
    "dest_lng" DOUBLE PRECISION NOT NULL,
    "polyline" TEXT,
    "total_distance_m" INTEGER,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "routes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "route_id" INTEGER,
    "started_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "ended_at" TIMESTAMP(6),
    "mode" VARCHAR(20) DEFAULT 'hybrid',

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "device_id" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6),
    "preferred_mode" VARCHAR(20) DEFAULT 'hybrid',
    "consent_research" BOOLEAN DEFAULT false,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_events_event_type" ON "events"("event_type");

-- CreateIndex
CREATE INDEX "idx_events_session_id" ON "events"("session_id");

-- CreateIndex
CREATE UNIQUE INDEX "landmarks_google_place_id_key" ON "landmarks"("google_place_id");

-- CreateIndex
CREATE INDEX "idx_landmarks_google_place_id" ON "landmarks"("google_place_id");

-- CreateIndex
CREATE INDEX "idx_navigation_steps_route_id" ON "navigation_steps"("route_id");

-- CreateIndex
CREATE INDEX "idx_sessions_route_id" ON "sessions"("route_id");

-- CreateIndex
CREATE INDEX "idx_sessions_user_id" ON "sessions"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_device_id_key" ON "users"("device_id");

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_step_id_fkey" FOREIGN KEY ("step_id") REFERENCES "navigation_steps"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "navigation_steps" ADD CONSTRAINT "navigation_steps_landmark_id_fkey" FOREIGN KEY ("landmark_id") REFERENCES "landmarks"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "navigation_steps" ADD CONSTRAINT "navigation_steps_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "routes"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "routes" ADD CONSTRAINT "routes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_route_id_fkey" FOREIGN KEY ("route_id") REFERENCES "routes"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
