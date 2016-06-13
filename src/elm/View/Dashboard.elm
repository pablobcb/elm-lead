module View.Dashboard exposing (..)

-- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Model.Model as Model exposing (..)
import Msg exposing (..)
import Components.OnScreenKeyboard exposing (..)
import View.Panel exposing (..)
import View.InformationBar exposing (informationBar)


dashboard : Model.Model -> Html Msg.Msg
dashboard model =
    div [ class "dashboard" ]
        [ panel model
        , keyboard OnScreenKeyboardMsg model.onScreenKeyboard
        , informationBar model.onScreenKeyboard
        ]
