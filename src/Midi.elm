module Midi exposing (..) -- where

import Dict
import Note exposing (..)

type alias MidiNote = Int
type alias MidiMessage = List Int

noteOn = 144
noteOff = 128

makeMidiMessage : MidiNote -> Velocity -> Int -> MidiMessage
makeMidiMessage note velocity type_ =
  [type_, note, velocity]


noteOnMessage : MidiNote -> Velocity -> MidiMessage
noteOnMessage note velocity =
  makeMidiMessage note velocity noteOn


noteOffMessage : MidiNote -> Velocity -> MidiMessage
noteOffMessage note velocity =
  makeMidiMessage note velocity noteOff


noteToMidiNumber : (Note, Octave) -> MidiNote
noteToMidiNumber note =
  let
    midiNoteNumbers = Dict.fromList list
  in
    case Dict.get (toString note) midiNoteNumbers of
      Just midiNoteNumber ->
        midiNoteNumber
      Nothing ->
        Debug.crash
          ("noteToMidiNumber expected a valid MIDI note" ++ (toString note))


list =
  List.map (\(key, value) -> (toString key, value))
    [ ((C , -2) , 0 )
    , ((Db, -2) , 1 )
    , ((D , -2) , 2 )
    , ((Eb, -2) , 3 )
    , ((E , -2) , 4 )
    , ((F , -2) , 5 )
    , ((Gb, -2) , 6 )
    , ((G , -2) , 7 )
    , ((Ab, -2) , 8 )
    , ((A , -2) , 9 )
    , ((Bb, -2) , 10 )
    , ((B , -2) , 11 )

    , ((C , -1) , 12 )
    , ((Db, -1) , 13 )
    , ((D , -1) , 14 )
    , ((Eb, -1) , 15 )
    , ((E , -1) , 16 )
    , ((F , -1) , 17 )
    , ((Gb, -1) , 18 )
    , ((G , -1) , 19 )
    , ((Ab, -1) , 20 )
    , ((A , -1) , 21 )
    , ((Bb, -1) , 22 )
    , ((B , -1) , 23 )

    , ((C , 0) , 24 )
    , ((Db, 0) , 25 )
    , ((D , 0) , 26 )
    , ((Eb, 0) , 27 )
    , ((E , 0) , 28 )
    , ((F , 0) , 29 )
    , ((Gb, 0) , 30 )
    , ((G , 0) , 31 )
    , ((Ab, 0) , 32 )
    , ((A , 0) , 33 )
    , ((Bb, 0) , 34 )
    , ((B , 0) , 35 )

    , ((C , 1) , 36 )
    , ((Db, 1) , 37 )
    , ((D , 1) , 38 )
    , ((Eb, 1) , 39 )
    , ((E , 1) , 40 )
    , ((F , 1) , 41 )
    , ((Gb, 1) , 42 )
    , ((G , 1) , 43 )
    , ((Ab, 1) , 44 )
    , ((A , 1) , 45 )
    , ((Bb, 1) , 46 )
    , ((B , 1) , 47 )

    , ((C , 2) , 48 )
    , ((Db, 2) , 49 )
    , ((D , 2) , 50 )
    , ((Eb, 2) , 51 )
    , ((E , 2) , 52 )
    , ((F , 2) , 53 )
    , ((Gb, 2) , 54 )
    , ((G , 2) , 55 )
    , ((Ab, 2) , 56 )
    , ((A , 2) , 57 )
    , ((Bb, 2) , 58 )
    , ((B , 2) , 59 )

    , ((C , 3) , 60 )
    , ((Db, 3) , 61 )
    , ((D , 3) , 62 )
    , ((Eb, 3) , 63 )
    , ((E , 3) , 64 )
    , ((F , 3) , 65 )
    , ((Gb, 3) , 66 )
    , ((G , 3) , 67 )
    , ((Ab, 3) , 68 )
    , ((A , 3) , 69 )
    , ((Bb, 3) , 70 )
    , ((B , 3) , 71 )

    , ((C , 4) , 72 )
    , ((Db, 4) , 73 )
    , ((D , 4) , 74 )
    , ((Eb, 4) , 75 )
    , ((E , 4) , 76 )
    , ((F , 4) , 77 )
    , ((Gb, 4) , 78 )
    , ((G , 4) , 79 )
    , ((Ab, 4) , 80 )
    , ((A , 4) , 81 )
    , ((Bb, 4) , 82 )
    , ((B , 4) , 83 )

    , ((C , 5) , 84 )
    , ((Db, 5) , 85 )
    , ((D , 5) , 86 )
    , ((Eb, 5) , 87 )
    , ((E , 5) , 88 )
    , ((F , 5) , 89 )
    , ((Gb, 5) , 90 )
    , ((G , 5) , 91 )
    , ((Ab, 5) , 92 )
    , ((A , 5) , 93 )
    , ((Bb, 5) , 94 )
    , ((B , 5) , 95 )

    , ((C , 6) , 96 )
    , ((Db, 6) , 97 )
    , ((D , 6) , 98 )
    , ((Eb, 6) , 99 )
    , ((E , 6) , 100 )
    , ((F , 6) , 101 )
    , ((Gb, 6) , 102 )
    , ((G , 6) , 103 )
    , ((Ab, 6) , 104 )
    , ((A , 6) , 105 )
    , ((Bb, 6) , 106 )
    , ((B , 6) , 107 )

    , ((C , 7) , 108 )
    , ((Db, 7) , 109 )
    , ((D , 7) , 110 )
    , ((Eb, 7) , 111 )
    , ((E , 7) , 112 )
    , ((F , 7) , 113 )
    , ((Gb, 7) , 114 )
    , ((G , 7) , 115 )
    , ((Ab, 7) , 116 )
    , ((A , 7) , 117 )
    , ((Bb, 7) , 118 )
    , ((B , 7) , 119 )

    , ((C , 8) , 120 )
    , ((Db, 8) , 121 )
    , ((D , 8) , 122 )
    , ((Eb, 8) , 123 )
    , ((E , 8) , 124 )
    , ((F , 8) , 125 )
    , ((Gb, 8) , 126 )
    , ((G , 8) , 127 )
    ]

