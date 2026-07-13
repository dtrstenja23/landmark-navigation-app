import { test } from 'node:test';
import assert from 'node:assert/strict';
import { scoreCandidates } from '../services/landmark-matcher.service.ts';

const ORIGIN = { lat: 45.0, lng: 16.0 };
const METERS_PER_DEGREE_LAT = 111320;

function pointAtDistance(meters: number) {
    return { lat: ORIGIN.lat + meters / METERS_PER_DEGREE_LAT, lng: ORIGIN.lng };
}

function makeCandidate(overrides: { id: string; name: string; primaryType: string; distanceMeters: number }) {
    return {
        id: overrides.id,
        displayName: { text: overrides.name, languageCode: 'hr' },
        location: { latitude: pointAtDistance(overrides.distanceMeters).lat, longitude: ORIGIN.lng },
        primaryType: overrides.primaryType,
        types: [overrides.primaryType]
    };
}

test('a close, well-typed candidate is selected', () => {
    const candidates = [
        makeCandidate({ id: 'p1', name: 'Konzum', primaryType: 'store', distanceMeters: 20 })
    ];

    const best = scoreCandidates(candidates, ORIGIN);

    assert.ok(best);
    assert.equal(best.id, 'p1');
    assert.equal(best.category, 'shop');
});

test('a candidate too far away for its category is rejected', () => {
    const candidates = [
        makeCandidate({ id: 'p1', name: 'Daleka zgrada', primaryType: 'store', distanceMeters: 50 })
    ];

    const best = scoreCandidates(candidates, ORIGIN);

    assert.equal(best, null);
});

test('an empty candidate list returns null', () => {
    const best = scoreCandidates([], ORIGIN);

    assert.equal(best, null);
});

test('the highest-scoring candidate wins among several passing the threshold', () => {
    const candidates = [
        makeCandidate({ id: 'far-shop', name: 'Dalja trgovina', primaryType: 'store', distanceMeters: 30 }),
        makeCandidate({ id: 'close-monument', name: 'Spomenik', primaryType: 'monument', distanceMeters: 10 }),
        makeCandidate({ id: 'close-shop', name: 'Bliza trgovina', primaryType: 'store', distanceMeters: 5 })
    ];

    const best = scoreCandidates(candidates, ORIGIN);

    assert.ok(best);
    assert.equal(best.id, 'close-monument');
});

test('a candidate exactly at the score threshold is accepted', () => {
    const candidates = [
        makeCandidate({ id: 'p1', name: 'Na granici', primaryType: 'unmapped_type', distanceMeters: 30 })
    ];

    const best = scoreCandidates(candidates, ORIGIN);

    assert.ok(best);
    assert.equal(best.id, 'p1');
});

test('an unmapped primaryType falls back to the building category', () => {
    const candidates = [
        makeCandidate({ id: 'p1', name: 'Nepoznat tip', primaryType: 'convenience_store', distanceMeters: 10 })
    ];

    const best = scoreCandidates(candidates, ORIGIN);

    assert.ok(best);
    assert.equal(best.category, 'building');
});
