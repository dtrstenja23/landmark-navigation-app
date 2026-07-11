import { generateRoutes } from "../clients/googleRoutes.client.ts";
import { generateInstruction } from "./instruction-generator.ts";
import { usersService } from "./users.service.ts";
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
};

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

        const navigationSteps: NavigationStepInput[] = route.legs[0].steps.map((step:any,index:number)=>{
            const maneuver = step.navigationInstruction?.maneuver ?? 'MANEUVER_UNSPECIFIED';
            const instruction = generateInstruction({
                maneuver,
                distanceMeters: step.distanceMeters,
                landmark: null,
                mode: params.mode
            });

            const navigationStep: NavigationStepInput = {
                step_index: index,
                instruction_text: instruction.text,
                distance_m: step.distanceMeters,
                maneuver,
                start_lat: step.startLocation.latLng.latitude,
                start_lng: step.startLocation.latLng.longitude,
                end_lat: step.endLocation.latLng.latitude,
                end_lng: step.endLocation.latLng.longitude,
                is_landmark_based: instruction.isLandmarkBased,
            };

            return navigationStep;
        });

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
            },
            user_id: user.id,
            steps: createdSteps.map((step) => ({
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
                landmark: null,
            })),
        };
    }
};