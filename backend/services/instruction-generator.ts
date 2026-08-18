const COMPASS = [
    'sjever', 'sjeveroistok', 'istok', 'jugoistok',
    'jug', 'jugozapad', 'zapad', 'sjeverozapad'
];

function calculateBearing(start: {lat: number; lng: number}, end: {lat: number; lng: number}): number {
    const toRad = (deg: number) => (deg * Math.PI) / 180;
    const deltaLng = toRad(end.lng - start.lng);
    const lat1 = toRad(start.lat);
    const lat2 = toRad(end.lat);

    const y = Math.sin(deltaLng) * Math.cos(lat2);
    const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(deltaLng);

    return (Math.atan2(y, x) * 180 / Math.PI + 360) % 360;
}

function bearingToCompass(bearingDeg: number): string {
    return COMPASS[Math.round(bearingDeg / 45) % 8];
}

const MANEUVER: Record<string,string> = {
    MANEUVER_UNSPECIFIED: 'nastavi ravno',
    TURN_SLIGHT_LEFT: 'skreni blago lijevo',
    TURN_SHARP_LEFT: 'skreni oštro lijevo',
    UTURN_LEFT: 'okreni se polukružno ulijevo',
    TURN_LEFT: 'skreni lijevo',
    TURN_SLIGHT_RIGHT: 'skreni blago desno',
    TURN_SHARP_RIGHT: 'skreni oštro desno',
    UTURN_RIGHT: 'okreni se polukružno udesno',
    TURN_RIGHT: 'skreni desno',
    STRAIGHT: 'nastavi ravno',
    RAMP_LEFT: 'uđi na rampu lijevo',
    RAMP_RIGHT: 'uđi na rampu desno',
    MERGE: 'uključi se u promet',
    FORK_LEFT: 'drži se lijevo na račvanju',
    FORK_RIGHT: 'drži se desno na račvanju',
    FERRY: 'ukrcaj se na trajekt',
    FERRY_TRAIN: 'ukrcaj se na vlak-trajekt',
    ROUNDABOUT_LEFT: 'na kružnom toku izađi lijevo',
    ROUNDABOUT_RIGHT: 'na kružnom toku izađi desno',
    NAME_CHANGE: 'nastavi ravno'
};

export type Instruction = {
    text:string;
    isLandmarkBased:boolean;
};

export function formatDistance(distanceMeters: number): string {
    if (distanceMeters >= 1000) {
        const km = (distanceMeters / 1000).toFixed(1);
        const formattedKm = km.endsWith('.0') ? km.slice(0, -2) : km.replace('.', ',');
        return `${formattedKm} km`;
    }

    if (distanceMeters >= 100) {
        const rounded = Math.round(distanceMeters / 50) * 50;
        if (rounded >= 1000) {
            return '1 km';
        }
        return `${rounded} m`;
    }

    const rounded = Math.max(10, Math.round(distanceMeters / 10) * 10);
    return `${rounded} m`;
}

const STRAIGHT_MANEUVERS = new Set(['NAME_CHANGE', 'STRAIGHT', 'MANEUVER_UNSPECIFIED']);

export function generateInstruction(params:{
    maneuver: string;
    distanceMeters: number;
    landmark: {name: string} | null;
    mode: 'hybrid' | 'landmark' | 'classic';
    isArrival?: boolean;
    isDepart?: boolean;
    start?: { lat: number; lng: number };
    end?: { lat: number; lng: number };
}):Instruction{
    const { maneuver, distanceMeters, landmark, mode, isArrival, isDepart, start, end } = params;

    if(isArrival){
        if (distanceMeters > 0) {
            return { text: `Za ${formatDistance(distanceMeters)} stižete na odredište`, isLandmarkBased: false };
        }
        return { text: 'Stigli ste na odredište', isLandmarkBased: false };
    }

    if(maneuver === 'DEPART'){
        const direction = start && end ? bearingToCompass(calculateBearing(start, end)) : null;
        return {
            text: direction ? `Kreni na ${direction}` : 'Kreni',
            isLandmarkBased: false
        };
    }

    const distanceFormatted = formatDistance(distanceMeters);
    let instruction: Instruction;

    if (STRAIGHT_MANEUVERS.has(maneuver)) {
        instruction = { text: `Nastavi ravno sljedećih ${distanceFormatted}`, isLandmarkBased: false };
    } else if (maneuver.startsWith('ROUNDABOUT')) {
        const exitDirection = maneuver === 'ROUNDABOUT_LEFT' ? 'izađi lijevo' : 'izađi desno';
        if (mode === 'classic' || landmark === null) {
            instruction = { text: `Za ${distanceFormatted} na kružnom toku ${exitDirection}`, isLandmarkBased: false };
        } else {
            const isRoundaboutLandmark = /rotor|kru[žz]ni/i.test(landmark.name);
            if (isRoundaboutLandmark) {
                if (mode === 'landmark') {
                    instruction = { text: `Na rotoru "${landmark.name}" ${exitDirection}`, isLandmarkBased: true };
                } else {
                    instruction = { text: `Za ${distanceFormatted} na rotoru "${landmark.name}" ${exitDirection}`, isLandmarkBased: true };
                }
            } else {
                if (mode === 'landmark') {
                    instruction = { text: `Na kružnom toku ${exitDirection} kod "${landmark.name}"`, isLandmarkBased: true };
                } else {
                    instruction = { text: `Za ${distanceFormatted} na kružnom toku ${exitDirection} kod "${landmark.name}"`, isLandmarkBased: true };
                }
            }
        }
    } else {
        const base = MANEUVER[maneuver] ?? MANEUVER.MANEUVER_UNSPECIFIED;
        if(mode === 'classic' || landmark === null){
            instruction = { text: `Za ${distanceFormatted} ${base}`, isLandmarkBased: false };
        }
        else if(mode === 'landmark'){
            instruction = { text: `${base.charAt(0).toUpperCase() + base.slice(1)} kod "${landmark.name}"`, isLandmarkBased: true };
        }
        else{
            instruction = { text: `Za ${distanceFormatted} ${base} kod "${landmark.name}"`, isLandmarkBased: true };
        }
    }

    if (isDepart && start && end) {
        const direction = bearingToCompass(calculateBearing(start, end));
        const lowerFirst = instruction.text.charAt(0).toLowerCase() + instruction.text.slice(1);
        return {
            text: `Kreni na ${direction}, ${lowerFirst}`,
            isLandmarkBased: instruction.isLandmarkBased
        };
    }

    return instruction;
}