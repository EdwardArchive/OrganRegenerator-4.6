// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import UM 1.2 as UM
import Cura 1.0 as Cura

Item
{
    id: extruderInfo
    property var printCoreConfiguration

    height: information.height

    //Extruder icon.
    Cura.RokitExtruderIcon
    {
        id: icon
        materialColor: printCoreConfiguration !== null ? printCoreConfiguration.material.color : ""
        anchors.verticalCenter: parent.verticalCenter
    }

    Column
    {
        id: information
        anchors
        {
            left: icon.right
            right: parent.right
            margins: UM.Theme.getSize("default_margin").width
        }

        Label
        {
            text: (printCoreConfiguration !== null && printCoreConfiguration.material.brand) ? printCoreConfiguration.material.brand : " " //Use space so that the height is still correct.
            renderType: Text.NativeRendering
            elide: Text.ElideRight
            font: UM.Theme.getFont("default")
            color: UM.Theme.getColor("text_inactive")
            width: parent.width
        }
        Label
        {
            text: (printCoreConfiguration !== null && printCoreConfiguration.material.brand) ? printCoreConfiguration.material.name : " " //Use space so that the height is still correct.
            renderType: Text.NativeRendering
            elide: Text.ElideRight
            font: UM.Theme.getFont("medium")
            color: UM.Theme.getColor("text")
            width: parent.width
        }
        Label
        {
            text: (printCoreConfiguration !== null && printCoreConfiguration.hotendID) ? printCoreConfiguration.hotendID : " " //Use space so that the height is still correct.
            renderType: Text.NativeRendering
            elide: Text.ElideRight
            font: UM.Theme.getFont("default")
            color: UM.Theme.getColor("text_inactive")
            width: parent.width
        }
    }
}
