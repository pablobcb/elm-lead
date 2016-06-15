module Midi exposing (..)

-- where

import Note as Note exposing (..)
import Dict exposing (..)


type alias MidiNote =
    Int


type alias MidiMessage =
    List Int


noteOn =
    144


noteOff =
    128


makeMidiMessage : MidiNote -> Velocity -> Int -> MidiMessage
makeMidiMessage note velocity type_ =
    [ type_, note, velocity ]


noteOnMessage : MidiNote -> Velocity -> MidiMessage
noteOnMessage note velocity =
    makeMidiMessage note velocity noteOn


noteOffMessage : MidiNote -> Velocity -> MidiMessage
noteOffMessage note velocity =
    makeMidiMessage note velocity noteOff


noteToMidiNumber : ( Note, Octave ) -> MidiNote
noteToMidiNumber note =
    case Dict.get (toString note) midiNotesDict of
        Just midiNoteNumber ->
            midiNoteNumber

        Nothing ->
            Debug.crash ("noteToMidiNumber expected a valid MIDI note" ++ (toString note))


midiNotesDict : Dict String MidiNote
midiNotesDict =
    let
        pianoNotes =
            (List.concat <| List.repeat 10 Note.octaveNotes)
                ++ (List.take 8 Note.octaveNotes)

        midiNotes =
            [0..127]

        octaves =
            (List.concat
                <| List.map
                    (\octave ->
                        List.repeat 12 octave
                    )
                    [-2..7]
            )
                ++ (List.repeat 8 8)
    in
        Dict.fromList
            <| List.map3
                (\pianoNote octave midiNote ->
                    ( toString ( pianoNote, octave ), midiNote )
                )
                pianoNotes
                octaves
                midiNotes