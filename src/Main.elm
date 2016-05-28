import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)
import Html.App as Html
import Html.Events exposing (onClick)
import Keyboard exposing (..)
import Debug exposing (..)
import Char exposing (..)

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
  { octave   : Int
  , velocity : Int
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


update : Msg -> Model -> (Model, Cmd msg)
update msg model =
  (,)
  (case msg of
    NoOp ->
      model

    OctaveDown ->
      octaveDown model

    OctaveUp ->
      octaveUp model

    VelocityDown ->
      velocityDown model

    VelocityUp ->
      velocityUp model
  )
  Cmd.none


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
subscriptions : Model -> Sub Msg
subscriptions model =
  Keyboard.presses (\ keyCode ->
    let
      symbol = keyCode |> fromCode |> toLower
    in
      if symbol == 'z' then
        OctaveDown

      else if symbol == 'x' then
        OctaveUp
        
      else if symbol == 'c' then
        VelocityDown
        
      else if symbol == 'v' then
        VelocityUp

      else
        NoOp
  )