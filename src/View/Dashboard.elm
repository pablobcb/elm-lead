module View.Dashboard exposing (..) -- where

import Html exposing (..)
import Html.Attributes exposing (..)

import Model.VirtualKeyboard exposing (VirtualKeyboardModel)
import Update exposing (..)
import Msg exposing (..)
import View.Keyboard exposing (keyboard)
import View.SynthPanel exposing (..)
import View.InformationBar exposing (informationBar)


dashboard : VirtualKeyboardModel -> Html Msg
dashboard model =
  div
    [ class "dashboard" ]
    [ synthPanel
    , keyboard model
    , informationBar model
    ]
