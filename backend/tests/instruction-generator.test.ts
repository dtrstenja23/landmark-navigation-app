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

test('distances >= 1000m format as kilometers with one decimal or whole number', () => {
    const instruction1 = generateInstruction({
        maneuver: 'TURN_RIGHT',
        distanceMeters: 2182,
        landmark: null,
        mode: 'classic'
    });
    assert.equal(instruction1.text, 'Za 2,2 km skreni desno');

    const instruction2 = generateInstruction({
        maneuver: 'TURN_LEFT',
        distanceMeters: 2000,
        landmark: null,
        mode: 'classic'
    });
    assert.equal(instruction2.text, 'Za 2 km skreni lijevo');

    const instruction3 = generateInstruction({
        maneuver: 'TURN_LEFT',
        distanceMeters: 1518,
        landmark: { name: 'Kapela' },
        mode: 'hybrid'
    });
    assert.equal(instruction3.text, 'Za 1,5 km skreni lijevo kod "Kapela"');
});

test('straight and name change maneuvers generate natural phrasing', () => {
    const instruction1 = generateInstruction({
        maneuver: 'NAME_CHANGE',
        distanceMeters: 720,
        landmark: null,
        mode: 'classic'
    });
    assert.equal(instruction1.text, 'Nastavi ravno sljedećih 700 m');

    const instruction2 = generateInstruction({
        maneuver: 'STRAIGHT',
        distanceMeters: 2200,
        landmark: { name: 'Konzum' },
        mode: 'hybrid'
    });
    assert.equal(instruction2.text, 'Nastavi ravno sljedećih 2,2 km');
    assert.equal(instruction2.isLandmarkBased, false);
});

test('roundabout with rotor landmark avoids redundant phrasing', () => {
    const instruction1 = generateInstruction({
        maneuver: 'ROUNDABOUT_RIGHT',
        distanceMeters: 68,
        landmark: { name: 'Rotor' },
        mode: 'hybrid'
    });
    assert.equal(instruction1.text, 'Za 70 m na rotoru "Rotor" izađi desno');

    const instruction2 = generateInstruction({
        maneuver: 'ROUNDABOUT_LEFT',
        distanceMeters: 120,
        landmark: { name: 'Zrinski trg' },
        mode: 'landmark'
    });
    assert.equal(instruction2.text, 'Na kružnom toku izađi lijevo kod "Zrinski trg"');
});


