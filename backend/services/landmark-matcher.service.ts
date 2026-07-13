import type { GooglePlacesResponse } from '../clients/googlePlaces.client.ts';
import type { landmarks } from '../generated/prisma/client.ts';
import { prisma } from '../config/db.ts';

type LandmarkCategory = 'monument' | 'transit_stop' | 'shop' | 'building';
type PlaceCandidate = NonNullable<GooglePlacesResponse['places']>[number];

const CATEGORY_BY_TYPE: Record<string, LandmarkCategory> = {
    monument: 'monument',
    historical_landmark: 'monument',
    tourist_attraction: 'monument',
    church: 'monument',
    transit_station: 'transit_stop',
    bus_stop: 'transit_stop',
    train_station: 'transit_stop',
    subway_station: 'transit_stop',
    store: 'shop',
    shopping_mall: 'shop',
    supermarket: 'shop',
    pharmacy: 'shop',
    bank: 'shop',
    cafe: 'shop',
    restaurant: 'shop'
};

const CATEGORY_WEIGHTS: Record<LandmarkCategory, number> = {
    monument: 3.0,
    transit_stop: 2.5,
    shop: 2.0,
    building: 1.5
};

export type ScoredLandmark = {
    id: string;
    name: string;
    lat: number;
    lng: number;
    category: LandmarkCategory;
    score: number;
};

const MIN_SCORE = 0;

export function scoreCandidates(
    candidates: PlaceCandidate[],
    point: { lat: number; lng: number }
): ScoredLandmark | null {
    let best: ScoredLandmark | null = null;

    for (const candidate of candidates) {
        const category = CATEGORY_BY_TYPE[candidate.primaryType ?? ''] ?? 'building';
        const typeWeight = CATEGORY_WEIGHTS[category];
        const distance = distanceMeters(point, {
            lat: candidate.location.latitude,
            lng: candidate.location.longitude
        });
        const score = typeWeight - 0.05 * distance;

        if (score >= MIN_SCORE && (!best || score > best.score)) {
            best = {
                id: candidate.id,
                name: candidate.displayName.text,
                lat: candidate.location.latitude,
                lng: candidate.location.longitude,
                category,
                score
            };
        }
    }

    return best;
}

function distanceMeters(a: { lat: number; lng: number }, b: { lat: number; lng: number }): number {
    const earthRadiusM = 6371000;
    const dLat = (b.lat - a.lat) * Math.PI / 180;
    const dLng = (b.lng - a.lng) * Math.PI / 180;
    const lat1 = a.lat * Math.PI / 180;
    const lat2 = b.lat * Math.PI / 180;

    const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
    return 2 * earthRadiusM * Math.asin(Math.sqrt(h));
}

export async function findCachedNear(point: { lat: number; lng: number }, radiusM = 50) {
    const { latDelta, lngDelta } = degreeDelta(point.lat, radiusM);

    const candidates = await prisma.landmarks.findMany({
        where: {
            lat: { gte: point.lat - latDelta, lte: point.lat + latDelta },
            lng: { gte: point.lng - lngDelta, lte: point.lng + lngDelta }
        }
    });

    let closest: landmarks | null = null;
    let closestDistance = Infinity;

    for (const candidate of candidates) {
        const distance = distanceMeters(point, { lat: candidate.lat, lng: candidate.lng });
        if (distance <= radiusM && distance < closestDistance) {
            closest = candidate;
            closestDistance = distance;
        }
    }

    return closest;
}

export async function upsertByPlaceId(landmark: {
    googlePlaceId: string;
    name: string;
    lat: number;
    lng: number;
    category: LandmarkCategory;
}) {
    return prisma.landmarks.upsert({
        where: { google_place_id: landmark.googlePlaceId },
        create: {
            name: landmark.name,
            lat: landmark.lat,
            lng: landmark.lng,
            type: landmark.category,
            google_place_id: landmark.googlePlaceId
        },
        update: {
            name: landmark.name,
            lat: landmark.lat,
            lng: landmark.lng,
            type: landmark.category
        }
    });
}

function degreeDelta(lat: number, meters: number) {
    const latitudeDegreeM = 111320;
    const latDelta = meters / latitudeDegreeM;
    const lngDelta = meters / (latitudeDegreeM * Math.cos(lat * Math.PI / 180));
    return { latDelta, lngDelta };
}