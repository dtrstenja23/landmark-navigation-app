import { generateRoutes } from "../clients/googleRoutes.client.ts";
import { generateInstruction } from "./instruction-generator.ts";
import { usersService } from "./users.service.ts";
import { findCachedNear, scoreCandidates, upsertByPlaceId } from "./landmark-matcher.service.ts";
import { searchNearbyPlaces, type GooglePlacesResponse } from "../clients/googlePlaces.client.ts";
import type { landmarks } from "../generated/prisma/client.ts";
import { prisma } from '../config/db.ts';
import { AppError } from '../utils/AppError.ts';

type NavigationStepInput = {
    step_index: number;
    instruction_text: string;
    distance_m: number;
    maneuver: string;
    start_lat: number;
    start_lng: number;
    end_lat: number;
    end_lng: number;
    is_landmark_based: boolean;
    landmark_id: number | null;
};

const SKIPPED_MANEUVERS = new Set(['DEPART']);

async function resolveLandmark(point: { lat: number; lng: number }) {
    const cached = await findCachedNear(point);
    if (cached) {
        return cached;
    }

    let response: GooglePlacesResponse;
    try {
        response = await searchNearbyPlaces(point);
    } catch (error) {
        console.error('Places API poziv nije uspio, koristim klasičnu uputu za ovaj korak:', error);
        return null;
    }

    const best = scoreCandidates(response.places ?? [], point);
    if (!best) {
        return null;
    }

    return upsertByPlaceId({
        googlePlaceId: best.id,
        name: best.name,
        lat: best.lat,
        lng: best.lng,
        category: best.category
    });
}

export const routeGenerationService = {
    async generate(params: {
        device_id: string;
        origin: { lat: number; lng: number };
        destination: { lat: number; lng: number };
        travel_mode: 'WALK' | 'DRIVE';
        mode: 'hybrid' | 'landmark' | 'classic';
    }){
        let user = await usersService.getByDeviceId(params.device_id);
        if(!user){
            user = await usersService.create({device_id:params.device_id});
        }

        const response = await generateRoutes({
            origin: params.origin,
            destination: params.destination,
            travel_mode: params.travel_mode
        });

        const route = response.routes?.[0];
        if(!route){
            throw new AppError("Ruta nije pronađena", 422);
        }

        const totalDurationS = parseInt(route.duration, 10) || null;

        const landmarksByStepIndex = new Map<number, landmarks>();

        const steps = route.legs[0].steps;

        const navigationSteps: NavigationStepInput[] = await Promise.all(
            steps.map(async (step, index) => {
                const maneuver = step.navigationInstruction?.maneuver ?? 'MANEUVER_UNSPECIFIED';
                const isArrival = index === steps.length - 1;
                const point = {
                    lat: step.startLocation.latLng.latitude,
                    lng: step.startLocation.latLng.longitude
                };

                const landmark = params.mode !== 'classic' && !isArrival && !SKIPPED_MANEUVERS.has(maneuver)
                    ? await resolveLandmark(point)
                    : null;

                if (landmark) {
                    landmarksByStepIndex.set(index, landmark);
                }

                const instruction = generateInstruction({
                    maneuver,
                    distanceMeters: step.distanceMeters,
                    landmark,
                    mode: params.mode,
                    isArrival,
                    start: point,
                    end: {
                        lat: step.endLocation.latLng.latitude,
                        lng: step.endLocation.latLng.longitude
                    }
                });

                const navigationStep: NavigationStepInput = {
                    step_index: index,
                    instruction_text: instruction.text,
                    distance_m: step.distanceMeters,
                    maneuver,
                    start_lat: point.lat,
                    start_lng: point.lng,
                    end_lat: step.endLocation.latLng.latitude,
                    end_lng: step.endLocation.latLng.longitude,
                    is_landmark_based: instruction.isLandmarkBased,
                    landmark_id: landmark?.id ?? null,
                };

                return navigationStep;
            })
        );

        const { createdRoute, createdSteps } = await prisma.$transaction(async (tx) => {
            const createdRoute = await tx.routes.create({
                data: {
                    user_id: user.id,
                    origin_lat: params.origin.lat,
                    origin_lng: params.origin.lng,
                    dest_lat: params.destination.lat,
                    dest_lng: params.destination.lng,
                    polyline: route.polyline.encodedPolyline,
                    total_distance_m: route.distanceMeters,
                    total_duration_s: totalDurationS,
                    travel_mode: params.travel_mode,
                },
            });

            const createdSteps = await tx.navigation_steps.createManyAndReturn({
                data: navigationSteps.map((step) => ({
                    ...step,
                    route_id: createdRoute.id,
                })),
            });

            return { createdRoute, createdSteps };
        });

        return {
            route: {
                id: createdRoute.id,
                polyline: createdRoute.polyline,
                total_distance_m: createdRoute.total_distance_m,
                total_duration_s: createdRoute.total_duration_s,
            },
            user_id: user.id,
            steps: createdSteps.map((step) => {
                const landmark = landmarksByStepIndex.get(step.step_index) ?? null;

                return {
                    id: step.id,
                    step_index: step.step_index,
                    instruction_text: step.instruction_text,
                    distance_m: step.distance_m,
                    maneuver: step.maneuver,
                    start_lat: step.start_lat,
                    start_lng: step.start_lng,
                    end_lat: step.end_lat,
                    end_lng: step.end_lng,
                    is_landmark_based: step.is_landmark_based,
                    landmark: landmark
                        ? { id: landmark.id, name: landmark.name, lat: landmark.lat, lng: landmark.lng, type: landmark.type }
                        : null,
                };
            }),
        };
    }
};