declare interface MIDIAccess : EventTarget {
    inputs: MIDIInputMap;
    outputs: MIDIOutputMap;
    onstatechange: EventHandler;
    sysexEnabled: bool;
}
