// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4

import UM 1.2 as UM
import Cura 1.0 as Cura


/**
 * Menu that allows you to select the configuration of the current printer, such
 * as the nozzle sizes and materials in each extruder.
 */
Cura.ExpandablePopup
{
    id: base

    property var extrudersModel:  Cura.ExtrudersModel{}  // CuraApplication.getExtrudersModel()

    UM.I18nCatalog
    {
        id: catalog
        name: "cura"
    }

    enum ConfigurationMethod
    {
        Auto,
        Custom
    }

    contentPadding: UM.Theme.getSize("default_lining").width
    enabled: Cura.MachineManager.activeMachine.hasMaterials || Cura.MachineManager.activeMachine.hasVariants || Cura.MachineManager.activeMachine.hasVariantBuildplates; //Only let it drop down if there is any configuration that you could change.

    headerItem: Cura.IconWithText
    {
        text: "Material"
        source: UM.Theme.getIcon("category_material")
        font: UM.Theme.getFont("medium")
        iconColor: UM.Theme.getColor("machine_selector_printer_icon")
        iconSize: source != "" ? UM.Theme.getSize("machine_selector_icon").width: 0
    }

    contentItem: Column
    {
        id: popupItem
        width: UM.Theme.getSize("configuration_selector").width
        height: implicitHeight  // Required because ExpandableComponent will try to use this to determine the size of the background of the pop-up.
        padding: UM.Theme.getSize("default_margin").height
        spacing: UM.Theme.getSize("default_margin").height

        property bool is_connected: false  // If current machine is connected to a printer. Only evaluated upon making popup visible.
        property int configuration_method: RokitConfigurationMenu.ConfigurationMethod.Custom  // Type of configuration being used. Only evaluated upon making popup visible.
        property int manual_selected_method: -1  // It stores the configuration method selected by the user. By default the selected method is

        onVisibleChanged:
        {
            // is_connected = Cura.MachineManager.activeMachine.hasRemoteConnection && Cura.MachineManager.printerConnected && Cura.MachineManager.printerOutputDevices[0].uniqueConfigurations.length > 0 //Re-evaluate.

            // If the printer is not connected or does not have configurations, we switch always to the custom mode. If is connected instead, the auto mode
            // or the previous state is selected
            configuration_method = is_connected ? (manual_selected_method == -1 ? RokitConfigurationMenu.ConfigurationMethod.Auto : manual_selected_method) : RokitConfigurationMenu.ConfigurationMethod.Custom
        }

        Item
        {
            width: parent.width - 2 * parent.padding
            height:
            {
                var height = 0
                if (autoConfiguration.visible)
                {
                    height += autoConfiguration.height
                }
                if (customConfiguration.visible)
                {
                    height += customConfiguration.height
                }
                return height
            }

            AutoConfiguration
            {
                id: autoConfiguration
                visible: popupItem.configuration_method == RokitConfigurationMenu.ConfigurationMethod.Auto
            }

            RokitCustomConfiguration
            {
                id: customConfiguration
                visible: popupItem.configuration_method == RokitConfigurationMenu.ConfigurationMethod.Custom
            }
        }

        Rectangle
        {
            id: separator
            visible: buttonBar.visible
            x: -parent.padding

            width: parent.width
            height: UM.Theme.getSize("default_lining").height

            color: UM.Theme.getColor("lining")
        }

        //Allow switching between custom and auto.
        Item
        {
            id: buttonBar
            visible: popupItem.is_connected //Switching only makes sense if the "auto" part is possible.

            width: parent.width - 2 * parent.padding
            height: childrenRect.height

            Cura.SecondaryButton
            {
                id: goToCustom
                visible: popupItem.configuration_method == RokitConfigurationMenu.ConfigurationMethod.Auto
                text: catalog.i18nc("@label", "Custom")

                anchors.right: parent.right

                iconSource: UM.Theme.getIcon("arrow_right")
                isIconOnRightSide: true

                onClicked:
                {
                    popupItem.configuration_method = RokitConfigurationMenu.ConfigurationMethod.Custom
                    popupItem.manual_selected_method = popupItem.configuration_method
                }
            }

            Cura.SecondaryButton
            {
                id: goToAuto
                visible: popupItem.configuration_method == RokitConfigurationMenu.ConfigurationMethod.Custom
                text: catalog.i18nc("@label", "Configurations")

                iconSource: UM.Theme.getIcon("arrow_left")

                onClicked:
                {
                    popupItem.configuration_method = RokitConfigurationMenu.ConfigurationMethod.Auto
                    popupItem.manual_selected_method = popupItem.configuration_method
                }
            }
        }
    }

    Connections
    {
        target: Cura.MachineManager
        onGlobalContainerChanged: popupItem.manual_selected_method = -1  // When switching printers, reset the value of the manual selected method
    }
}
