module Preset exposing (..)

import Midi exposing (..)


type alias Preset =
    { number : Int
    , name : String
    , filter :
        { type_ : String
        , frequency : MidiValue
        , q : MidiValue
        , envelopeAmount : MidiValue
        , amp :
            { attack : MidiValue
            , decay : MidiValue
            , sustain : MidiValue
            , release : MidiValue
            }
        }
    , amp :
        { attack : MidiValue
        , decay : MidiValue
        , sustain : MidiValue
        , release : MidiValue
        , masterVolume : MidiValue
        }
    , oscs :
        { osc1 :
            { waveformType : String
            , fmGain : MidiValue
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
