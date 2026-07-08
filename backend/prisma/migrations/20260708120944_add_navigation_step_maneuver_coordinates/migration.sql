-- AlterTable
ALTER TABLE "navigation_steps" ADD COLUMN     "maneuver" VARCHAR(50),
ADD COLUMN     "start_lat" DOUBLE PRECISION,
ADD COLUMN     "start_lng" DOUBLE PRECISION,
ADD COLUMN     "end_lat" DOUBLE PRECISION,
ADD COLUMN     "end_lng" DOUBLE PRECISION;
