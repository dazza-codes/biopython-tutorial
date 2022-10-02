"""
Configure the invoke release task
"""

from invoke_release.plugins import PatternReplaceVersionInFilesPlugin
from invoke_release.tasks import *  # noqa: F403

configure_release_parameters(  # noqa: F405
    module_name="biopython_tutorial",
    display_name="biopython-tutorial",
    # python_directory="package",
    plugins=[
        PatternReplaceVersionInFilesPlugin(
            "biopython_tutorial/version.py", "pyproject.toml", "README.md"
        )
    ],
)
