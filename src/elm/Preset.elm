module Preset exposing (..)

import Midi exposing (..)


type alias Preset =
    { filter :
        { type_ : String
        , distortion : Bool
        , frequency : MidiValue
        , q : MidiValue
        , envelopeAmount : MidiValue
        , amp :
            { attack : MidiValue
            , decay : MidiValue
            , sustain : MidiValue
            , release : MidiValue
            , masterVolume : MidiValue
            }
        }
    , amp :
        { attack : MidiValue
        , decay : MidiValue
        , sustain : MidiValue
        , release : MidiValue
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
    }
