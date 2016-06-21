module Note exposing (..)

-- where


type alias Octave =
    Int


type alias Velocity =
    Int


type Note
    = C
    | Db
    | D
    | Eb
    | E
    | F
    | Gb
    | G
    | Ab
    | A
    | Bb
    | B


octaveNotes : List Note
octaveNotes =
    [ C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B ]
