module Main.View exposing (..)

import Main.Model as Model exposing (..)
import Html.Attributes exposing (..)
import Html exposing (..)
import Container.OnScreenKeyboard.View as KbdView exposing (..)
import Container.Panel.View as PanelView exposing (..)
import Main.Update as Update exposing (..)
import Component.InformationBar exposing (informationBar)


view : Model -> Html Update.Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel PanelMsg
            model.panel
          --, div [ class "panel__brand" ]
          --[ span [] [ text "web lead" ]
          --, span [] [ text "2X" ]
          --, span [] [ text "virtual analog" ]
          --]
        , KbdView.keyboard OnScreenKeyboardMsg
            model.onScreenKeyboard
        , informationBar model
        ]
