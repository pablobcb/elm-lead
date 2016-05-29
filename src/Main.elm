import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.App as Html
import Html.Events exposing (onClick)
import Keyboard exposing (..)
import Debug exposing (..)
import Char exposing (..)
import MyPort exposing (..)
import Note exposing (..)
import MIDI exposing (..)

-- Main
main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- Model
type alias Model =
  { octave   : Octave
  , velocity : Velocity
  }


-- Init
init : (Model, Cmd msg)
init =
  (,)
  { octave   = 3
  , velocity = 100
  }
  Cmd.none

-- Update
type Msg
  = NoOp
  | OctaveUp
  | OctaveDown
  | VelocityUp
  | VelocityDown
  | KeyOn Char
  --| NoteOn Note
  | NoteOff Note


update : Msg -> Model -> (Model, Cmd msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    OctaveDown ->
      (octaveDown model, Cmd.none)

    OctaveUp ->
      (octaveUp model, Cmd.none)

    VelocityDown ->
      (velocityDown model, Cmd.none)

    VelocityUp ->
      (velocityUp model,  Cmd.none)

    KeyOn symbol ->
      let
        velocity = .velocity model
        octave   = .octave model

        midiNoteNumber =
          noteToMIDINumber <|
            case symbol of
              'a' -> ( C  , octave )
              'w' -> ( Db , octave )
              's' -> ( D  , octave )
              'e' -> ( Eb , octave )
              'd' -> ( E  , octave )
              'f' -> ( F  , octave )
              't' -> ( Gb , octave )
              'g' -> ( G  , octave )
              'y' -> ( Ab , octave )
              'h' -> ( A  , octave )
              'u' -> ( Bb , octave )
              'j' -> ( B  , octave )
              'k' -> ( C  , octave + 1 )
              'o' -> ( Db , octave + 1 )
              'l' -> ( D  , octave + 1 )
              _ -> Debug.crash "shouldnt happen"
      in
        (model, makeMidiMessage midiNoteNumber model.velocity |> noteOn)


    NoteOff note->
      (model, Cmd.none)


--noteOn : NoteRepresentation -> Model
--noteOn {octave, velocity, note} =
--  Debug.log "AEEEEE"



velocityDown : Model -> Model
velocityDown model =
  let
    vel = .velocity model

  in
    { model | velocity =
      if vel < 40 then
        1
      else if vel == 127 then
        120
      else
        vel - 20
    }


velocityUp : Model -> Model
velocityUp model =
  let
    vel = .velocity model

  in
    { model | velocity =
      if vel == 1 then
        20
      else if vel >= 120 then
        127
      else
        vel + 20
    }


octaveDown : Model -> Model
octaveDown model =
  { model | octave = max (-2) ((.octave model) - 1) }


octaveUp : Model -> Model
octaveUp model =
  { model | octave = min 8 (model |> .octave |> (+) 1) }


-- View
view : Model -> Html Msg
view model =
  virtualKeyboard model

virtualKeyboard : Model -> Html Msg
virtualKeyboard model =
  let
    startOctave =
      model |> .octave |> toString

    endOctave =
      model |> .octave |> (+) 1 |> toString

    octaveText =
      "Octave is C" ++ startOctave ++ " to C" ++ endOctave

    velocityText =
      ("Velocity is " ++ (model |> .velocity |> toString))

  in
    div
      [ class "virtual-keyboard" ]
      [ div [] [ octaveText |> text ]
      , div [] [ velocityText |> text ]
      ]

-- Subscriptions
handleKey : Keyboard.KeyCode -> Msg
handleKey keyCode =
  case keyCode |> Char.fromCode |> toLower of
  -- Keyboard Controls
    'z' ->
      OctaveDown

    'x' ->
      OctaveUp

    'c' ->
      VelocityDown

    'v' ->
      VelocityUp

  -- Notes
    symbol ->
      KeyOn symbol


subscriptions : Model -> Sub Msg
subscriptions model =
  Keyboard.presses handleKey
