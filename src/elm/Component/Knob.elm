module Component.Knob exposing (..)

--where

import Html exposing (Html, button, div, text, img)
import Html.Events exposing (onClick)
import Html.App exposing (map)
import Html.Attributes exposing (draggable, style, class, alt, src)
import Json.Decode as Json exposing (succeed, int, (:=))


-- MODEL


type alias YPos =
    Int


type alias Model =
    { value : Int
    , initialValue : Int
    , min : Int
    , max : Int
    , step : Int
    , initMouseYPos : Int
    , mouseYPos : Int
    , isMouseClicked : Bool
    , cmdEmitter : Int -> Cmd Msg
    , idKey : KnobInstance
    }


init : KnobInstance -> Int -> Int -> Int -> Int -> (Int -> Cmd Msg) -> Model
init idKey value min max step cmdEmitter =
    { value = value
    , initialValue = value
    , min = min
    , max = max
    , step = step
    , initMouseYPos = 0
    , mouseYPos = 0
    , isMouseClicked = False
    , cmdEmitter = cmdEmitter
    , idKey = idKey
    }


type Msg
    = MouseMove YPos
    | MouseDown KnobInstance YPos
    | MouseUp
    | Reset KnobInstance


type KnobInstance
    = OscMix
    | PW
    | Osc2Semitone
    | Osc2Detune
    | FM
    | AmpGain
    | AmpAttack
    | AmpDecay
    | AmpSustain
    | FilterCutoff
    | FilterQ
    



-- VIEW


knobStyle : List ( String, String )
knobStyle =
    [ ( "-webkit-user-select", "none" )
    , ( "-moz-user-select", "-moz-none" )
    , ( "-khtml-user-select", "none" )
    , ( "-ms-user-select", "none" )
    , ( "user-select", "none" )
    ]


view : Model -> Html Msg
view model =
    let
        -- These are defined in terms of degrees, with 0 pointing straight up
        visualMinimum = -140
        visualMaximum = 140
        visualRange = 280

        valueRange = (model.max - model.min)
        value = (toFloat model.value) / (toFloat valueRange)

        direction = visualMinimum + (value * visualRange)
        direction' = (toString direction) ++ "deg"
        knobStyle = [("transform", "rotate(" ++ direction' ++ ")")]

        mapPosition msg =
            Json.map (\posY -> msg posY) ("layerY" := int)
    in
        img
            [ Html.Events.on "mousedown" <| mapPosition (MouseDown model.idKey)
            , Html.Events.on "dblclick" <| succeed <| Reset model.idKey
            , class "knob__dial"
            , style knobStyle
            , alt "oops!"
            , src "knob-fg.svg"
            ]
            [ div [ class "knob__indicator"]
                [ Html.text (toString model.value) ]
            ]


knob : (Msg -> a) -> Model -> Html a
knob knobMsg model =
    Html.App.map knobMsg
        <| view model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Reset idKey ->
            if model.idKey /= idKey then
                ( model, Cmd.none )
            else
                ( { model | value = model.initialValue }
                , model.cmdEmitter model.initialValue
                )

        MouseDown idKey mouseYPos ->
            if model.idKey /= idKey then
                ( model, Cmd.none )
            else
                ( { model
                    | initMouseYPos = mouseYPos
                    , mouseYPos = mouseYPos
                    , isMouseClicked = True
                  }
                , Cmd.none
                )

        MouseUp ->
            ( { model | isMouseClicked = False }, Cmd.none )

        MouseMove mouseYPos ->
            let
                direction =
                    (model.initMouseYPos - mouseYPos)
                        // abs (model.initMouseYPos - mouseYPos)

                newValue =
                    model.value
                        + (direction * model.step)
            in
                if not model.isMouseClicked then
                    ( model, Cmd.none )
                else if newValue > model.max then
                    ( { model
                        | value = model.max
                        , initMouseYPos = mouseYPos
                      }
                    , Cmd.none
                    )
                else if newValue < model.min then
                    ( { model
                        | value = model.min
                        , initMouseYPos = mouseYPos
                      }
                    , Cmd.none
                    )
                else
                    ( { model
                        | value = newValue
                        , initMouseYPos = mouseYPos
                      }
                    , model.cmdEmitter newValue
                    )
