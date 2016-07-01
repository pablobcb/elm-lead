module Preset exposing (..)


type alias Preset =
    { filter :
        { type_ : String
        , distortion : Bool
        , frequency : Int
        , q : Int
        , envelopeAmount : Int
        , amp :
            { attack : Int
            , decay : Int
            , sustain : Int
            , release : Int
            }
        }
    , amp :
        { attack : Int
        , decay : Int
        , sustain : Int
        , release : Int
        }
    , oscs :
        { osc1 :
            { waveformType : String
            , gain : Int
            , fmGain : Int
            }
        , osc2 :
            { waveformType : String
            , gain : Int
            , semitone : Int
            , detune : Int
            , kbdTrack : Bool
            }
        , pw : Int
        }
    , masterVolume : Int
    }
