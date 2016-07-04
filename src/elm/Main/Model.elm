module Main.Model exposing (..)

import Container.OnScreenKeyboard.Model as KbdModel exposing (..)
import Container.Panel.Model as PanelModel exposing (..)
import Preset

type alias InitialFlags =
    { preset : Preset.Preset
    , midiSupport : Bool
    }

type alias Model =
    { onScreenKeyboard : KbdModel.Model
    , panel : PanelModel.Model
    , midiConnected : Bool
    , searchingMidi : Bool
    , midiMsgInLedOn : Bool
    , midiSupport : Bool
    }


initModel : InitialFlags -> Model
initModel flags =
    { onScreenKeyboard = KbdModel.init
    , panel = PanelModel.init flags.preset
    , midiConnected = False
    , searchingMidi = True
    , midiMsgInLedOn = False
    , midiSupport = flags.midiSupport
    }


updateOnScreenKeyboard : KbdModel.Model -> Model -> Model
updateOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }


updatePanel : PanelModel.Model -> Model -> Model
updatePanel panel model =
    { model | panel = panel }
