module Knob exposing (..)

-- where

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.App exposing (map)
import Html.Attributes exposing (draggable, style)
import Json.Decode as Json exposing (..)


-- MODEL


type alias Model =
    { value : Int
    , min : Int
    , max : Int
    , step : Int
    , yPos : Int
    }


create : Int -> Int -> Int -> Int -> Model
create value min max step =
    { value = value
    , min = min
    , max = max
    , step = step
    , yPos = 0
    }


type alias YPos =
    Int


type alias Value =
    Int


type Msg
    = ValueChange (Value -> Cmd Msg) YPos
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
        <| view (\value -> value |> cmdEmmiter)
            model


updateMap :
    parentModel
    -> Msg
    -> (parentModel -> Model)
    -> (Model -> parentModel -> parentModel)
    -> (Msg -> c)
    -> ( parentModel, Cmd c )
updateMap parentModel msg getField reduxor parentMsg =
    let
        ( updatedKnobModel, knobCmd ) =
            update msg (getField parentModel)
    in
        ( reduxor updatedKnobModel parentModel
        , Cmd.map parentMsg knobCmd
        )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MouseDragStart yPos ->
            ( { model | yPos = yPos }, Cmd.none )

        ValueChange cmdEmmiter yPos ->
            let
                newValue =
                    if yPos < model.yPos then
                        model.value + model.step
                    else if yPos > model.yPos then
                        model.value - model.step
                    else
                        model.value
            in
                if newValue > model.max || newValue < model.min then
                    ( model, Cmd.none )
                else
                    ( { model | value = newValue }
                    , cmdEmmiter newValue
                    )
