# Copyright (c) 2015 Ultimaker B.V.
# Uranium is released under the terms of the LGPLv3 or higher.

from . import RokitUpdateChecker


def getMetaData():
    return {
    }

def register(app):
    return { "extension": RokitUpdateChecker.RokitUpdateChecker() }
