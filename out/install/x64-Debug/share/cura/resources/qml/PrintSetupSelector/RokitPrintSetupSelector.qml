// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import UM 1.3 as UM
import Cura 1.0 as Cura

Cura.ExpandablePopup {
    id: printSetupSelector

    // dragPreferencesNamePrefix: "view/settings"

    property bool preSlicedData: PrintInformation !== null && PrintInformation.preSliced

    contentPadding: UM.Theme.getSize("default_lining").width
    // contentHeaderTitle: catalog.i18nc("@label", "Layer Quality")
    enabled: !preSlicedData
    disabledText: catalog.i18nc("@label shown when we load a Gcode file", "Print setup disabled. G-code file can not be modified.")

    UM.I18nCatalog {
        id: catalog
        name: "cura"
    }

    headerItem: Cura.IconWithText {
        text: "Print Quality"
        source: UM.Theme.getIcon("category_layer_height")
        font: UM.Theme.getFont("medium")
        iconColor: UM.Theme.getColor("machine_selector_printer_icon")
        iconSize: source != "" ? UM.Theme.getSize("machine_selector_icon").width: 0
    }

    property var extrudersModel: CuraApplication.getExtrudersModel()

    contentItem: RokitPrintSetupSelectorContents {}

    onExpandedChanged: UM.Preferences.setValue("view/settings_visible", expanded)
    Component.onCompleted: expanded = UM.Preferences.getValue("view/settings_visible")
}
