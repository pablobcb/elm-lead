module Main.Model exposing (..)

import Container.OnScreenKeyboard.Model as KbdModel exposing (..)
import Container.Panel.Model as PanelModel exposing (..)
import Preset

type alias Model =
    { onScreenKeyboard : KbdModel.Model
    , panel : PanelModel.Model
    , midiConnected : Bool
    , searchingMidi : Bool
    , midiMsgInLedOn : Bool
    }


initModel : Preset.Preset -> Model
initModel preset =
    { onScreenKeyboard = KbdModel.init
    , panel = PanelModel.init preset
    , midiConnected = False
    , searchingMidi = True
    , midiMsgInLedOn = False
    }


updateOnScreenKeyboard : KbdModel.Model -> Model -> Model
updateOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }


updatePanel : PanelModel.Model -> Model -> Model
updatePanel panel model =
    { model | panel = panel }
