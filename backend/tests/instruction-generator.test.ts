import { test } from 'node:test';
import assert from 'node:assert/strict';
import { generateInstruction } from '../services/instruction-generator.ts';

test('classic mode ignores landmark even when one is found', () => {
    const instruction = generateInstruction({
        maneuver: 'TURN_RIGHT',
        distanceMeters: 300,
        landmark: { name: 'Konzum' },
        mode: 'classic'
    });

    assert.equal(instruction.text, 'Za 300 m skreni desno');
    assert.equal(instruction.isLandmarkBased, false);
});

test('landmark mode drops the distance prefix', () => {
    const instruction = generateInstruction({
        maneuver: 'TURN_RIGHT',
        distanceMeters: 300,
        landmark: { name: 'Konzum' },
        mode: 'landmark'
    });

    assert.equal(instruction.text, 'Skreni desno kod "Konzum"');
    assert.equal(instruction.isLandmarkBased, true);
});

test('hybrid mode keeps both the distance and the landmark', () => {
    const instruction = generateInstruction({
        maneuver: 'TURN_RIGHT',
        distanceMeters: 300,
        landmark: { name: 'Konzum' },
        mode: 'hybrid'
    });

    assert.equal(instruction.text, 'Za 300 m skreni desno kod "Konzum"');
    assert.equal(instruction.isLandmarkBased, true);
});

test('arrival step always wins, regardless of mode or landmark', () => {
    const instruction = generateInstruction({
        maneuver: 'TURN_LEFT',
        distanceMeters: 24,
        landmark: { name: 'Restoran Barok' },
        mode: 'hybrid',
        isArrival: true
    });

    assert.equal(instruction.text, 'Stigli ste na odredište');
    assert.equal(instruction.isLandmarkBased, false);
});

test('landmark mode without a found landmark falls back to classic text', () => {
    const instruction = generateInstruction({
        maneuver: 'TURN_RIGHT',
        distanceMeters: 300,
        landmark: null,
        mode: 'landmark'
    });

    assert.equal(instruction.text, 'Za 300 m skreni desno');
    assert.equal(instruction.isLandmarkBased, false);
});

test('hybrid mode without a found landmark falls back to classic text', () => {
    const instruction = generateInstruction({
        maneuver: 'TURN_RIGHT',
        distanceMeters: 300,
        landmark: null,
        mode: 'hybrid'
    });

    assert.equal(instruction.text, 'Za 300 m skreni desno');
    assert.equal(instruction.isLandmarkBased, false);
});

test('unknown maneuver falls back to "nastavi ravno"', () => {
    const instruction = generateInstruction({
        maneuver: 'SOME_UNMAPPED_MANEUVER',
        distanceMeters: 50,
        landmark: null,
        mode: 'classic'
    });

    assert.equal(instruction.text, 'Za 50 m nastavi ravno');
});

test('landmark mode capitalizes the first letter of the maneuver text', () => {
    const instruction = generateInstruction({
        maneuver: 'ROUNDABOUT_LEFT',
        distanceMeters: 120,
        landmark: { name: 'Zrinski trg' },
        mode: 'landmark'
    });

    assert.equal(instruction.text, 'Na kružnom toku izađi lijevo kod "Zrinski trg"');
});
