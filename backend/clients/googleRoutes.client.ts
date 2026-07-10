import {env} from '../config/env.ts';

const FIELD_MASK = [
    'routes.legs.steps.navigationInstruction',
    'routes.legs.steps.startLocation',
    'routes.legs.steps.endLocation',
    'routes.legs.steps.distanceMeters',
    'routes.legs.steps.polyline',
    'routes.duration',
    'routes.distanceMeters',
    'routes.polyline.encodedPolyline'
].join(',');

type LatLng = {lat:number; lng:number;};

export type GoogleRoutesResponse = {
    routes: {
        distanceMeters: number;
        polyline: { encodedPolyline: string };
        legs: {
            steps: {
                distanceMeters: number;
                navigationInstruction?: { maneuver: string; instructions: string };
                startLocation: { latLng: { latitude: number; longitude: number } };
                endLocation: { latLng: { latitude: number; longitude: number } };
            }[];
        }[];
    }[];
};

export async function generateRoutes(params:{
    origin: LatLng;
    destination: LatLng;
    travel_mode: 'WALK' | 'DRIVE';
}){
    const body: Record<string, unknown>={
        origin: {location:{latLng:{latitude:params.origin.lat, longitude:params.origin.lng}}},
        destination: {location:{latLng:{latitude:params.destination.lat, longitude:params.destination.lng}}},
        travelMode: params.travel_mode,
        languageCode: 'hr',
        units: 'METRIC',
        computeAlternativeRoutes: false
    };

    if(params.travel_mode === 'DRIVE'){
        body.routingPreference = 'TRAFFIC_AWARE';
        body.routeModifiers = { avoidTolls: false, avoidHighways: false, avoidFerries: false };
    }

    const response = await fetch('https://routes.googleapis.com/directions/v2:computeRoutes',{
        method: 'POST',
        headers: {
            'Content-Type':'application/json',
            'X-Goog-Api-Key':env.GOOGLE_MAPS_API_KEY,
            'X-Goog-FieldMask':FIELD_MASK
        },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(10000)
    });

    if(!response.ok){
        throw new Error(`Routes API error: ${response.status} ${await response.text()}`);
    }

    return response.json() as Promise<GoogleRoutesResponse>;
}