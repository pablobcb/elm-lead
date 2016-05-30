module View.Keyboard exposing (keyboard) -- where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)

import Update exposing (Msg)

keyboard : Html Msg
keyboard =
  let
    keys = List.concat <| List.repeat 7
      [ li [ class "key lower c"   ] []
      , li [ class "key higher cs" ] []
      , li [ class "key lower d"   ] []
      , li [ class "key higher ds" ] []
      , li [ class "key lower e"   ] []
      , li [ class "key lower f"   ] []
      , li [ class "key higher fs" ] []
      , li [ class "key lower g"   ] []
      , li [ class "key higher gs" ] []
      , li [ class "key lower a"   ] []
      , li [ class "key higher as" ] []
      , li [ class "key lower b"   ] []
      ]
  in
    ul [ class "keyboard" ] keys

