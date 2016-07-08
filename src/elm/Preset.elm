module Preset exposing (..)

import Midi exposing (..)


type alias Preset =
    { name : String
    , presetId : Int
    , filter :
        { type_ : String
        , frequency : MidiValue
        , q : MidiValue
        , envelopeAmount : MidiValue
        , adsr :
            { attack : MidiValue
            , decay : MidiValue
            , sustain : MidiValue
            , release : MidiValue
            }
        }
    , amp :
        { adsr :
            { attack : MidiValue
            , decay : MidiValue
            , sustain : MidiValue
            , release : MidiValue
            }
        , masterVolume : MidiValue
        }
    , oscs :
        { osc1 :
            { waveformType : String
            , fmAmount : MidiValue
            }
        , osc2 :
            { waveformType : String
            , semitone : MidiValue
            , detune : MidiValue
            , kbdTrack : Bool
            }
        , pw : MidiValue
        , mix : MidiValue
        }
    , overdrive : Bool
    }
