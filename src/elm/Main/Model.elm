module Main.Model
    exposing
        ( init
        , Model
        , InitialFlags
        , updateOnScreenKeyboard
        , updatePanel
        )

import Container.OnScreenKeyboard.Model as KbdModel
import Container.Panel.Model as PanelModel
import Preset


type alias InitialFlags =
    { preset : Preset.Preset
    , midiSupport : Bool
    }


type alias Model =
    { onScreenKeyboard : KbdModel.Model
    , panel : PanelModel.Model
    , midiConnected : Bool
    , midiMsgInLedOn : Bool
    , midiSupport : Bool
    , presetName : String
    , presetId : Int
    }


init : Preset.Preset -> Bool -> Model
init preset midiSupport =
    { onScreenKeyboard = KbdModel.init
    , panel = PanelModel.init preset
    , midiConnected = False
    , midiMsgInLedOn = False
    , midiSupport = midiSupport
    , presetName = preset.name
    , presetId = preset.presetId
    }


updateOnScreenKeyboard : KbdModel.Model -> Model -> Model
updateOnScreenKeyboard keyboard model =
    { model | onScreenKeyboard = keyboard }


updatePanel : PanelModel.Model -> Model -> Model
updatePanel panel model =
    { model | panel = panel }
