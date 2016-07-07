module Main.View exposing (view)

import Main.Model as Model exposing (Model)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Container.OnScreenKeyboard.View as KbdView
import Container.Panel.View as PanelView
import Main.Update as Update
import Component.InformationBar exposing (informationBar)


view : Model -> Html Update.Msg
view model =
    div [ class "dashboard" ]
        [ PanelView.panel Update.PanelMsg
            model.panel
          --, div [ class "panel__brand" ]
          --[ span [] [ text "web lead" ]
          --, span [] [ text "2X" ]
          --, span [] [ text "virtual analog" ]
          --]
        , KbdView.keyboard Update.OnScreenKeyboardMsg
            model.onScreenKeyboard
        , informationBar model
        ]
