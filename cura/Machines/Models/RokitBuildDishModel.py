# Copyright (c) 2019 Ultimaker B.V.
# Cura is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import Qt, QPointF
from PyQt5.QtGui import QVector3D

from UM.Logger import Logger
from UM.Qt.ListModel import ListModel
import cura.CuraApplication  # Imported like this to prevent circular dependencies.

class RokitBuildDishModel(ListModel):
    ProductIdRole = Qt.UserRole + 1
    ShapeRole = Qt.UserRole + 2
    VolumeRole = Qt.UserRole + 3
    TripRole = Qt.UserRole + 4

    def __init__(self, parent = None):
        super().__init__(parent)

        self.addRoleName(self.ProductIdRole, "product_id")
        self.addRoleName(self.ShapeRole, "shape")
        self.addRoleName(self.VolumeRole, "volume")
        self.addRoleName(self.TripRole, "trip")

        # cura.CuraApplication.CuraApplication.getInstance().getMachineManager().globalContainerChanged.connect(self._update)
  
        Logger.log("d", "initialize {model_class_name}.".format(model_class_name = self.__class__.__name__))

        item_list = []
        item_list.append({"product_id": "Well Plate:96", "shape": "elliptic", "volume": QVector3D(6.5, 6.5, 10.8), "trip": {"line_seq":96/8, "spacing":9.0, "z": 10.8, "start_point": QPointF(74.0,49.5)}})
        item_list.append({"product_id": "Well Plate:48", "shape": "elliptic", "volume": QVector3D(9.75, 9.75, 17.50), "trip": {"line_seq":48/6, "spacing":14.43, "z": 17.50, "start_point": QPointF(10.0,12.0)}})
        item_list.append({"product_id": "Well Plate:24", "shape": "elliptic", "volume": QVector3D(15.5, 15.5, 17.50), "trip": {"line_seq":24/4, "spacing":19.5, "z": 17.50, "start_point": QPointF(11.5,13.5)}})
        item_list.append({"product_id": "Well Plate:12", "shape": "elliptic", "volume": QVector3D(21.9, 21.9, 17.50), "trip": {"line_seq":12/3, "spacing":28.87, "z": 17.50, "start_point": QPointF(14.0,18.0)}})
        item_list.append({"product_id": "Well Plate:6", "shape": "elliptic", "volume": QVector3D(35.0, 35.0, 17.50), "trip": {"line_seq":6/2, "spacing":38.5, "z": 17.50, "start_point": QPointF(21.0,23.0)}})

        item_list.append({"product_id": "Culture Dish:11035", "shape": "elliptic", "volume": QVector3D(35,35,10)})
        item_list.append({"product_id": "Culture Dish:11060", "shape": "elliptic", "volume": QVector3D(60,60,10)})
        item_list.append({"product_id": "Culture Dish:11090", "shape": "elliptic", "volume": QVector3D(90,90,15)})

        item_list.append({"product_id": "Culture Slide:11035", "shape": "rectangular", "volume": QVector3D(20,40,12)})
        item_list.append({"product_id": "Culture Slide:11060", "shape": "rectangular", "volume": QVector3D(30,60,12)})
        item_list.append({"product_id": "Culture Slide:11090", "shape": "rectangular", "volume": QVector3D(40,80,12)})

        self.setItems(item_list)
