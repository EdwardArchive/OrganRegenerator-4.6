// Copyright (c) 2019 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.
import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Controls 1.1 as OldControls

import Cura 1.0 as Cura
import UM 1.3 as UM

Item {
    id: base

    property var extrudersModel: Cura.ExtrudersModel{} 
    
    function getActiveExtruderId() {
        const activeExtruder = extrudersModel.getItem(tabBar.currentIndex)
        return (activeExtruder !== undefined) ? activeExtruder.id : ""
    }

    function getActiveExtruderName() {
        const activeExtruder = extrudersModel.getItem(tabBar.currentIndex)
        return (activeExtruder !== undefined) ? activeExtruder.name : ""
    }

    property var forceUpdateFunction: manager.forceUpdate

    function updateMaterialDiameter()
    {
        manager.updateMaterialForDiameter(extruderPosition)
    }

    UM.I18nCatalog {id: catalog; name: "cura" }

    width: parent.width
    height: childrenRect.height

    Label {
        id: header
        text: catalog.i18nc("@header", "Material and Nozzle Configuration")
        font: UM.Theme.getFont("medium")
        color: UM.Theme.getColor("small_button_text")
        height: contentHeight
        renderType: Text.NativeRendering
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    UM.TabRow {
        id: tabBar

        anchors.top: header.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        visible: extrudersModel.count > 1

        Repeater {
            id: repeater
            model: extrudersModel
            delegate: UM.TabRowButton {
                contentItem: Item {
                    Cura.RokitExtruderIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        materialColor: model.color
                        width: parent.height
                        height: parent.height
                    }
                }
                onClicked: {
                    Cura.ExtruderManager.setActiveExtruderIndex(tabBar.currentIndex)
                }
            }
        }

        //When active extruder changes for some other reason, switch tabs.
        //Don't directly link currentIndex to Cura.ExtruderManager.activeExtruderIndex!
        //This causes a segfault in Qt 5.11. Something with VisualItemModel removing index -1. We have to use setCurrentIndex instead.
        Connections {
            target: Cura.ExtruderManager
            onActiveExtruderChanged: {
                tabBar.setCurrentIndex(Cura.ExtruderManager.activeExtruderIndex);
            }
        }

        // Can't use 'item: ...activeExtruderIndex' directly apparently, see also the comment on the previous block.
        onVisibleChanged: {
            if (tabBar.visible) {
                tabBar.setCurrentIndex(Cura.ExtruderManager.activeExtruderIndex);
            }
        }

        //When the model of the extruders is rebuilt, the list of extruders is briefly emptied and rebuilt.
        //This causes the currentIndex of the tab to be in an invalid position which resets it to 0.
        //Therefore we need to change it back to what it was: The active extruder index.
        Connections {
            target: repeater.model
            onModelChanged: {
                tabBar.setCurrentIndex(Cura.ExtruderManager.activeExtruderIndex)
            }
        }
    }

    Rectangle {
        width: parent.width
        height: childrenRect.height
        anchors.top: tabBar.bottom

        radius: tabBar.visible ? UM.Theme.getSize("default_radius").width : 0
        border.width: tabBar.visible ? UM.Theme.getSize("default_lining").width : 0
        border.color: UM.Theme.getColor("lining")
        color: UM.Theme.getColor("main_background")

        //Remove rounding and lining at the top.
        Rectangle {
            width: parent.width
            height: parent.radius
            anchors.top: parent.top
            color: UM.Theme.getColor("lining")
            visible: tabBar.visible
            Rectangle {
                anchors {
                    left: parent.left
                    leftMargin: parent.parent.border.width
                    right: parent.right
                    rightMargin: parent.parent.border.width
                    top: parent.top
                }
                height: parent.parent.radius
                color: parent.parent.color
            }
        }

        Column {
            id: selectors

            padding: UM.Theme.getSize("default_margin").width
            spacing: UM.Theme.getSize("default_margin").height

            readonly property real paddedWidth: parent.width - padding * 2
            property real textWidth: Math.round(paddedWidth * 0.3)
            property real controlWidth: {
                if(instructionLink == "") {
                    return paddedWidth - textWidth
                }
                else {
                    return paddedWidth - textWidth - UM.Theme.getSize("print_setup_big_item").height * 0.5 - UM.Theme.getSize("default_margin").width
                }
            }
            property string instructionLink: Cura.MachineManager.activeStack != null ? Cura.ContainerManager.getContainerMetaDataEntry(Cura.MachineManager.activeStack.material.id, "instruction_link", ""): ""

            // Row
            // {
            //     height: visible ? UM.Theme.getSize("setting_control").height : 0
            //     visible: extrudersModel.count > 1  // If there is only one extruder, there is no point to enable/disable that.

            //     Label
            //     {
            //         text: catalog.i18nc("@label", "Enabled")
            //         verticalAlignment: Text.AlignVCenter
            //         font: UM.Theme.getFont("default")
            //         color: UM.Theme.getColor("text")
            //         height: parent.height
            //         width: selectors.textWidth
            //         renderType: Text.NativeRendering
            //     }

            //     OldControls.CheckBox
            //     {
            //         id: enabledCheckbox
            //         checked: Cura.MachineManager.activeStack != null ? Cura.MachineManager.activeStack.isEnabled : false
            //         enabled: !checked || Cura.MachineManager.numberExtrudersEnabled > 1 //Disable if it's the last enabled extruder.
            //         height: parent.height
            //         style: UM.Theme.styles.checkbox

            //         /* Use a MouseArea to process the click on this checkbox.
            //            This is necessary because actually clicking the checkbox
            //            causes the "checked" property to be overwritten. After
            //            it's been overwritten, the original link that made it
            //            depend on the active extruder stack is broken. */
            //         MouseArea
            //         {
            //             anchors.fill: parent
            //             onClicked: Cura.MachineManager.setExtruderEnabled(Cura.ExtruderManager.activeExtruderIndex, !parent.checked)
            //             enabled: parent.enabled
            //         }
            //     }
            // }

            Row { // Nozzle
                height: UM.Theme.getSize("print_setup_big_item").height

                Label {
                    text: (getActiveExtruderName() === "Left") ? Cura.MachineManager.activeDefinitionVariantsName : "Needle Gauge"
                    verticalAlignment: Text.AlignVCenter
                    font: UM.Theme.getFont("default")
                    color: UM.Theme.getColor("text")
                    height: parent.height
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }

                OldControls.ToolButton {
                    id: variantSelection
                    text: Cura.MachineManager.activeStack != null ? Cura.MachineManager.activeStack.variant.name : ""
                    tooltip: text
                    height: parent.height
                    width: selectors.controlWidth
                    style: UM.Theme.styles.print_setup_header_button
                    activeFocusOnPress: true
                    menu: Cura.RokitNozzleMenu { extruderIndex: Cura.ExtruderManager.activeExtruderIndex }
                }
            }
            
            Row { // Material
                height: UM.Theme.getSize("print_setup_big_item").height

                Label {
                    text: catalog.i18nc("@label", "Material")
                    verticalAlignment: Text.AlignVCenter
                    font: UM.Theme.getFont("default")
                    color: UM.Theme.getColor("text")
                    height: parent.height
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }

                OldControls.ToolButton {
                    id: materialSelection

                    property bool valueError: Cura.MachineManager.activeStack !== null ? Cura.ContainerManager.getContainerMetaDataEntry(Cura.MachineManager.activeStack.material.id, "compatible", "") !== "True" : true
                    property bool valueWarning: !Cura.MachineManager.isActiveQualitySupported

                    text: Cura.MachineManager.activeStack !== null ? Cura.MachineManager.activeStack.material.name : ""
                    tooltip: text

                    width: selectors.controlWidth
                    height: parent.height

                    style: UM.Theme.styles.print_setup_header_button
                    activeFocusOnPress: true
                    menu: Cura.MaterialMenu {
                        extruderIndex: Cura.ExtruderManager.activeExtruderIndex
                        updateModels: materialSelection.visible
                    }
                }
                Item {
                    width: instructionButton.width + 2 * UM.Theme.getSize("default_margin").width
                    height: instructionButton.visible ? materialSelection.height: 0
                    Button {
                        id: instructionButton
                        hoverEnabled: true
                        contentItem: Item {}
                        height: 0.5 * materialSelection.height
                        width: height
                        anchors.centerIn: parent
                        background: UM.RecolorImage
                        {
                            source: UM.Theme.getIcon("printing_guideline")
                            color: instructionButton.hovered ? UM.Theme.getColor("primary") : UM.Theme.getColor("icon")
                        }
                        visible: selectors.instructionLink != ""
                        onClicked:Qt.openUrlExternally(selectors.instructionLink)
                    }
                }
            }


            Row {
                id: warnings
                height: visible ? childrenRect.height : 0
                visible: buildplateCompatibilityError || buildplateCompatibilityWarning

                property bool buildplateCompatibilityError: !Cura.MachineManager.variantBuildplateCompatible && !Cura.MachineManager.variantBuildplateUsable
                property bool buildplateCompatibilityWarning: Cura.MachineManager.variantBuildplateUsable

                // This is a space holder aligning the warning messages.
                Label {
                    text: ""
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }
                Item {
                    width: selectors.controlWidth
                    height: childrenRect.height

                    UM.RecolorImage {
                        id: warningImage
                        anchors.left: parent.left
                        source: UM.Theme.getIcon("warning")
                        width: UM.Theme.getSize("section_icon").width
                        height: UM.Theme.getSize("section_icon").height
                        sourceSize.width: width
                        sourceSize.height: height
                        color: UM.Theme.getColor("material_compatibility_warning")
                        visible: !Cura.MachineManager.isCurrentSetupSupported || warnings.buildplateCompatibilityError || warnings.buildplateCompatibilityWarning
                    }
                    Label {
                        id: materialCompatibilityLabel
                        anchors.left: warningImage.right
                        anchors.leftMargin: UM.Theme.getSize("default_margin").width
                        verticalAlignment: Text.AlignVCenter
                        width: selectors.controlWidth - warningImage.width - UM.Theme.getSize("default_margin").width
                        text: catalog.i18nc("@label", "Use glue for better adhesion with this material combination.")
                        font: UM.Theme.getFont("default")
                        color: UM.Theme.getColor("text")
                        visible: CuraSDKVersion == "dev" ? false : warnings.buildplateCompatibilityError || warnings.buildplateCompatibilityWarning
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }
                }
            }

            // Row {
            //     height: visible ? UM.Theme.getSize("print_setup_big_item").height : 0
            //     visible: Cura.MachineManager.activeMachine.hasVariants

            //     Cura.NumericTextFieldWithUnit  // "Nozzle size"
            //     {
            //         //id: extruderNozzleSizeField
            //         visible: Cura.MachineManager.activeMachine.hasVariants
            //         containerStackId: activeExtruderId
            //         settingKey: "material_diameter"
            //         settingStoreIndex: 0
            //         labelText: catalog.i18nc("@label", "material_diameter")
            //         labelFont: UM.Theme.getFont("default")
            //         labelWidth: selectors.textWidth - 8
            //         controlWidth: selectors.controlWidth
            //         controlHeight: parent.height
            //         unitText: catalog.i18nc("@label", "mm")
            //         forceUpdateOnChangeFunction: forceUpdateFunction
            //     }
            // }

            Row  { // material_print_temperature
                height: UM.Theme.getSize("print_setup_big_item").height

                Cura.NumericTextFieldWithUnit {
                    containerStackId: base.getActiveExtruderId()
                    settingKey: "material_print_temperature"
                    settingStoreIndex: 0
                    labelText: catalog.i18nc("@label", "Print Temperature")
                    labelFont: UM.Theme.getFont("default")
                    labelWidth: selectors.textWidth - 8
                    controlWidth: selectors.controlWidth
                    controlHeight: parent.height
                    unitText: catalog.i18nc("@label", "??C")
                    forceUpdateOnChangeFunction: forceUpdateFunction

                }
            }

            Row  { // material_bed_temperature
                height: UM.Theme.getSize("print_setup_big_item").height

                Cura.NumericTextFieldWithUnit {
                    containerStackId: base.getActiveExtruderId()
                    settingKey: "material_bed_temperature"
                    settingStoreIndex: 0
                    labelText: catalog.i18nc("@label", "Bed Temperature")
                    labelFont: UM.Theme.getFont("default")
                    labelWidth: selectors.textWidth - 10
                    controlWidth: selectors.controlWidth
                    controlHeight: parent.height
                    unitText: catalog.i18nc("@label", "??C")
                    forceUpdateOnChangeFunction: forceUpdateFunction

                }
            }
            
        }
    }
}
