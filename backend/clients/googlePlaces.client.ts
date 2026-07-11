import {env} from '../config/env.ts';

const FIELD_MASK = [
    'places.id',
    'places.displayName',
    'places.location',
    'places.primaryType',
    'places.types'
].join(',');

const LANDMARK_TYPES = [
    'monument',
    'historical_landmark',
    'church',
    'tourist_attraction',
    'transit_station',
    'bus_stop',
    'train_station',
    'subway_station',
    'store',
    'shopping_mall',
    'supermarket',
    'pharmacy',
    'bank',
    'cafe',
    'restaurant'
];

export type GooglePlacesRequest = {
    includedTypes: string[];
    maxResultCount: number;
    locationRestriction: {
        circle: {
            center: {
                latitude: number;
                longitude: number;
            };
            radius: number;
        }
    };
    languageCode: string;
};

export type GooglePlacesResponse = {
    places?:{
        id: string;
        displayName: {
            text: string;
            languageCode: string;
        };
        location: {
            latitude: number;
            longitude: number;
        };
        primaryType?: string;
        types: string[];
    }[];
};

export async function searchNearbyPlaces(params:{
    lat: number;
    lng: number;
}){
    const body: GooglePlacesRequest = {
        includedTypes: LANDMARK_TYPES,
        maxResultCount: 10,
        locationRestriction: {
            circle: {
                center: { latitude: params.lat, longitude: params.lng },
                radius: 50
            }
        },
        languageCode: 'hr'
    };

    const response = await fetch('https://places.googleapis.com/v1/places:searchNearby',{
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
        throw new Error(`Places API error: ${response.status} ${await response.text()}`);
    }
    
    return response.json() as Promise<GooglePlacesResponse>;
}