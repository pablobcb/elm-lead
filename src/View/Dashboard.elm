module View.Dashboard exposing (..) -- where

import Html exposing (..)
import Html.Attributes exposing (..)

import Model.VirtualKeyboard exposing (VirtualKeyboardModel)
import Update
import View.Keyboard exposing (keyboard)
import View.InformationBar exposing (informationBar)


dashboard : VirtualKeyboardModel -> Html Update.Msg
dashboard model =
  div
    [ class "dashboard" ]
    [ keyboard
    , informationBar model
    ]
