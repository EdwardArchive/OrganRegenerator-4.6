// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4

import UM 1.2 as UM
import Cura 1.0 as Cura

Menu {
    id: menu
    title: "Nozzle"

    property int extruderIndex: 0

    Cura.NozzleModel {
        id: nozzleModel
    }

    Instantiator {
        model:  nozzleModel 
    
        MenuItem  {
            text: model.hotend_name
            checkable: true
            checked: {
                var activeMachine = Cura.MachineManager.activeMachine
                if (activeMachine === null) {
                    return false
                }
                var extruder = Cura.MachineManager.activeMachine.extruderList[extruderIndex]
                return (extruder === undefined) ? false : (extruder.variant.name == model.hotend_name)
            }
            exclusiveGroup: group
            enabled: {
                var activeMachine = Cura.MachineManager.activeMachine
                var LeftHotEnds = ["Dispenser G19 0.79", "Dispenser G20 0.64","Dispenser G23 0.41", "Dispenser G27 0.23"]
                var RightHotEnds = ["Extruder Precision 0.2mm","Extruder Precision 0.4mm",
                    "Hot Melt Heigh Precision 0.2mm","Hot Melt Heigh Precision 0.4mm",
                    "Hot Melt Precision 0.2mm","Hot Melt Precision 0.4mm"]

                if (activeMachine === null || (extruderIndex > 0 && (RightHotEnds.indexOf(model.hotend_name) != -1))
                    || (extruderIndex == 0 && (LeftHotEnds.indexOf(model.hotend_name) != -1)) )  {
                    return false
                }
                var extruder = activeMachine.extruderList[extruderIndex]
                return (extruder === undefined) ? false : extruder.isEnabled
            }
            onTriggered: {
                Cura.MachineManager.setVariant(menu.extruderIndex, model.container_node);
            }
        }

        onObjectAdded: menu.insertItem(index, object);
        onObjectRemoved: menu.removeItem(object);
    }

    ExclusiveGroup { id: group }
}
