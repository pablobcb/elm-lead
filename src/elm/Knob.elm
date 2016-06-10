module Knob exposing (..)

-- where

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (draggable, style)
import Html.App exposing (map)
import Json.Decode as Json exposing (..)


-- MODEL


type alias Model =
    { value : Int
    , min : Int
    , max : Int
    , step : Int
    , yPos : Int
    }


initialModel : Model
initialModel =
    { value = 50
    , min = 0
    , max = 100
    , step = 1
    , yPos = 0
    }


type alias YPos =
    Int


type alias Value =
    Int


type Msg
    = ValueChange (Value -> Cmd Msg) YPos
    | MouseDrag YPos
    | MouseDragStart YPos


knobStyle : List ( String, String )
knobStyle =
    [ ( "-webkit-user-drag", "element" )
    , ( "-webkit-user-select", "none" )
    ]



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
            , style knobStyle
            ]
            [ Html.text (toString model.value) ]


knob : (Msg -> a) -> (Int -> Cmd Msg) -> Model -> Html a
knob knobMsg cmdEmmiter model =
    Html.App.map knobMsg
        <| view (\value -> cmdEmmiter value)
            model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MouseDrag yPos ->
            ( model, Cmd.none )

        MouseDragStart yPos ->
            ( { model | yPos = yPos }, Cmd.none )

        ValueChange cmdEmmiter currentYPos ->
            let
                op =
                    if currentYPos < model.yPos then
                        (+)
                    else
                        (-)

                newValue =
                    model.value `op` model.step
            in
                if newValue > model.max || newValue < model.min then
                    ( model, Cmd.none )
                else
                    ( { model | value = newValue }
                    , cmdEmmiter newValue
                    )
