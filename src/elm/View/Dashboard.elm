module View.Dashboard exposing (..)

-- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Model.Model exposing (Model)
import Msg exposing (..)
import View.Keyboard exposing (keyboard)
import View.SynthPanel exposing (..)
import View.InformationBar exposing (informationBar)


dashboard : Model -> Html Msg
dashboard model =
    div [ class "dashboard" ]
        [ synthPanel model
        , keyboard model
        , informationBar model
        ]
