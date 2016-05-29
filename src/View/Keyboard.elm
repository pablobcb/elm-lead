module View.Keyboard exposing (keyboard) -- where

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)

import Update exposing (Msg)

keyboard : Html Msg
keyboard =
  ul
    [ class "keyboard" ]
    [ li [ class "key white c"  ] []
    , li [ class "key black cs" ] []
    , li [ class "key white d"  ] []
    , li [ class "key black ds" ] []
    , li [ class "key white e"  ] []
    , li [ class "key white f"  ] []
    , li [ class "key black fs" ] []
    , li [ class "key white g"  ] []
    , li [ class "key black gs" ] []
    , li [ class "key white a"  ] []
    , li [ class "key black as" ] []
    , li [ class "key white b"  ] []
    ]
