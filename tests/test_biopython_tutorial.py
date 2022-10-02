from types import ModuleType

import biopython_tutorial


def test_biopython_tutorial():
    assert isinstance(biopython_tutorial, ModuleType)
