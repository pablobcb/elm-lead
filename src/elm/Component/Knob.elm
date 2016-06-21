module Component.Knob exposing (..)

--where

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.App exposing (map)
import Html.Attributes exposing (draggable, style, class)
import Json.Decode as Json exposing (..)


-- MODEL


type alias YPos =
    Int


type alias Value =
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
    , cmdEmitter : Value -> Cmd Msg
    , idKey :
        KnobInstance
        --TODOtransform in a
    }


init : KnobInstance -> Value -> Value -> Value -> Value -> (Value -> Cmd Msg) -> Model
init idKey value min max step cmdEmitter =
    { value = value
    , initialValue = value
    , min = min
    , max = max
    , step = step * 20
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
        mapPosition msg =
            Json.map (\posY -> msg posY) ("layerY" := int)
    in
        div
            [ Html.Events.on "mousedown" <| mapPosition (MouseDown model.idKey)
            , Html.Events.on "dblclick" <| succeed <| Reset model.idKey
            , class "knob__dial"
            , style knobStyle
            ]
            [ Html.text (toString model.value) ]



--knob : (Msg -> a) -> Model -> Html a


knob knobMsg model =
    Html.App.map knobMsg
        <| view model



-- UPDATE
--update : Msg -> Model a -> ( Model a, Cmd Msg )


update message model =
    case message of
        Reset idKey ->
            Debug.log "Reset"
                <| if model.idKey /= idKey then
                    ( model, Cmd.none )
                   else
                    ( { model | value = model.initialValue }
                    , model.cmdEmitter model.initialValue
                    )

        MouseDown idKey mouseYPos ->
            Debug.log "MouseDown"
                <| if model.idKey /= idKey then
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
            Debug.log "MouseUp"
                ( { model | isMouseClicked = False }
                , Cmd.none
                )

        MouseMove mouseYPos ->
            let
                _ =
                    Debug.log "MouseUp" mouseYPos

                newValue =
                    model.value
                        + (model.initMouseYPos - mouseYPos)
                        // abs (model.initMouseYPos - mouseYPos)
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
