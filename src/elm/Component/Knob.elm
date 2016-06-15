module Component.Knob exposing (..)

-- where

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.App exposing (map)
import Html.Attributes exposing (draggable, style, class)
import Json.Decode as Json exposing (..)


-- MODEL


type alias Model =
    { value : Int
    , min : Int
    , max : Int
    , step : Int
    , initYPos : Int
    , yPos : Int
    }


init : Int -> Int -> Int -> Int -> Model
init value min max step =
    { value = value
    , min = min
    , max = max
    , step = step * 20
    , initYPos = 0
    , yPos = 0
    }


type alias YPos =
    Int


type alias Value =
    Int


type Msg
    = ValueChange (Value -> Cmd Msg) YPos
    | MouseDragStart YPos



-- VIEW


view : (Int -> Cmd Msg) -> Model -> Html Msg
view cmdEmmiter model =
    let
        positionMap msg =
            Json.map (\posY -> msg posY) ("layerY" := int)
    in
        div
            [ Html.Events.on "drag" <| positionMap <| ValueChange cmdEmmiter
            , Html.Events.on "dragstart" <| positionMap MouseDragStart
            , class "knob__dial"
            ]
            [ Html.text (toString model.value) ]


knob : (Msg -> a) -> (Int -> Cmd Msg) -> Model -> Html a
knob knobMsg cmdEmmiter model =
    Html.App.map knobMsg
        <| view (\value -> value |> cmdEmmiter)
            model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MouseDragStart yPos ->
            ( { model | initYPos = yPos, yPos = yPos }, Cmd.none )

        ValueChange cmdEmmiter yPos ->
            let
                newValue =
                    model.value
                        + (model.initYPos - yPos)
                        // abs (model.initYPos - yPos)
            in
                if newValue > model.max then
                    ( { model | value = model.max, initYPos = yPos }, Cmd.none )
                else if newValue < model.min then
                    ( { model | value = model.min, initYPos = yPos }, Cmd.none )
                else
                    ( { model | value = newValue, initYPos = yPos }
                    , cmdEmmiter newValue
                    )
