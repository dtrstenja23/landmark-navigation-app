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
    DEPART: 'kreni',
    NAME_CHANGE: 'nastavi ravno'
};

export type Instruction = {
    text:string;
    isLandmarkBased:boolean;
};

export function generateInstruction(params:{
    maneuver: string;
    distanceMeters: number;
    landmark: {name: string} | null;
    mode: 'hybrid' | 'landmark' | 'classic';
    isArrival?: boolean;
}):Instruction{
    const { maneuver, distanceMeters, landmark, mode, isArrival } = params;

    if(isArrival){
        return { text: 'Stigli ste na odredište', isLandmarkBased: false };
    }

    const base = MANEUVER[maneuver] ?? MANEUVER.MANEUVER_UNSPECIFIED;
    let instruction : Instruction;
    if(mode === 'classic' || landmark === null){
        instruction = {text:`Za ${distanceMeters} m ${base}`, isLandmarkBased: false};
    }
    else if(mode === 'landmark'){
        instruction = {text:`${base.charAt(0).toUpperCase() + base.slice(1)} kod "${landmark.name}"`, isLandmarkBased: true};
    }
    else{
        instruction = { text: `Za ${distanceMeters} m ${base} kod "${landmark.name}"`, isLandmarkBased: true};
    }

    return instruction;
}