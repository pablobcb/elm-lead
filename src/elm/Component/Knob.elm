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
    , label : String
    , initMouseYPos : Int
    , mouseYPos : Int
    , isMouseClicked : Bool
    , cmdEmitter : Int -> Cmd Msg
    , idKey : KnobInstance
    }


init : KnobInstance -> Int -> Int -> Int -> Int -> String -> (Int -> Cmd Msg) -> Model
init idKey value min max step label cmdEmitter =
    { value = value
    , initialValue = value
    , min = min
    , max = max
    , step = step * 3
    , label = label
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
    | NoOp


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
    | AmpRelease
    | FilterCutoff
    | FilterQ
    | FilterAttack
    | FilterDecay
    | FilterSustain
    | FilterRelease
    | FilterEnvelopeAmount



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
        visualMinimum =
            -150

        visualMaximum =
            150

        visualRange =
            300

        valueRange =
            (model.max - model.min)

        value =
            (toFloat model.value) / (toFloat valueRange)

        direction =
            visualMinimum
                + (value * visualRange)
                + if model.min < 0 then
                    visualRange / 2
                  else
                    0

        direction' =
            (toString direction) ++ "deg"

        knobStyle =
            [ ( "transform", "rotate(" ++ direction' ++ ")" ) ]

        mapPosition msg =
            Json.map (\posY -> msg posY) ("layerY" := int)
    in
        div [ class "knob" ]
            [ div [ class "knob__scale" ]
                [ div
                    [ Html.Events.on "mousedown" <| mapPosition (MouseDown model.idKey)
                    , Html.Events.on "dblclick" <| succeed <| Reset model.idKey
                    , Html.Events.onWithOptions "dragstart"
                        { stopPropagation = True, preventDefault = True }
                        <| succeed
                        <| NoOp
                    , class "knob__dial"
                    , Html.Attributes.attribute "draggable" "false"
                    , style knobStyle
                    ]
                    []
                ]
            , div [ class "knob__label" ]
                [ text model.label ]
            ]


knob : (Msg -> a) -> Model -> Html a
knob knobMsg model =
    Html.App.map knobMsg
        <| view model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        NoOp ->
            ( model, Cmd.none )

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
                model' =
                    { model | initMouseYPos = mouseYPos }

                direction =
                    (model.initMouseYPos - mouseYPos)
                        // abs (model.initMouseYPos - mouseYPos)

                newValue =
                    model.value
                        + (direction * model.step)
            in
                if not model'.isMouseClicked then
                    ( model', Cmd.none )
                else if newValue > model'.max then
                    ( { model' | value = model'.max }, Cmd.none )
                else if newValue < model.min then
                    ( { model' | value = model.min }, Cmd.none )
                else
                    ( { model' | value = newValue }, model.cmdEmitter newValue )
