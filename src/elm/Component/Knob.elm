module Component.Knob exposing (..)

--where

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.App exposing (map)
import Html.Attributes exposing (draggable, style, class)
import Json.Decode as Json exposing (..)


-- MODEL


type alias Model =
    { value : Int
    , initialValue : Int
    , min : Int
    , max : Int
    , step : Int
    , initMouseYPos : Int
    , mouseYPos : Int
    , isMouseClicked : Bool
    }


init : Int -> Int -> Int -> Int -> Model
init value min max step =
    { value = value
    , initialValue = value
    , min = min
    , max = max
    , step = step * 20
    , initMouseYPos = 0
    , mouseYPos = 0
    , isMouseClicked = False
    }


type alias YPos =
    Int


type alias Value =
    Int


type Msg
    = MouseMove (YPos -> Cmd Msg) YPos
    | MouseDown YPos
    | MouseUp
    | Reset (Value -> Cmd Msg)



-- VIEW


knobStyle : List ( String, String )
knobStyle =
    [ ( "-webkit-user-select", "none" )
    , ( "-moz-user-select", "-moz-none" )
    , ( "-khtml-user-select", "none" )
    , ( "-ms-user-select", "none" )
    , ( "user-select", "none" )
    ]


view : (Int -> Cmd Msg) -> Model -> Html Msg
view cmdEmmiter model =
    let
        mapPosition msg =
            Json.map (\posY -> msg posY) ("layerY" := int)
    in
        div
            [ Html.Events.on "mousedown" <| mapPosition MouseDown
            , Html.Events.on "dblclick" <| succeed <| Reset cmdEmmiter
            , class "knob__dial"
            , style knobStyle
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
        Reset cmdEmmiter ->
            ( { model | value = model.initialValue }
            , cmdEmmiter model.initialValue
            )

        MouseDown mouseYPos ->
            ( { model
                | initMouseYPos = mouseYPos
                , mouseYPos = mouseYPos
                , isMouseClicked = True
              }
            , Cmd.none
            )

        MouseUp ->
            ( { model | isMouseClicked = False }, Cmd.none )

        MouseMove cmdEmmiter mouseYPos ->
            let
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
                    , cmdEmmiter newValue
                    )
