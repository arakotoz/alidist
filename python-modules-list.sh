package: Python-modules-list
version: "1.0"
env:
  PIP_BASE_REQUIREMENTS: |
    pip == 21.3.1; python_version < '3.12'
    pip == 24.3.1; python_version >= '3.12'
    setuptools == 59.6.0; python_version < '3.12'
    setuptools == 75.6.0; python_version >= '3.12'
    wheel == 0.37.1; python_version < '3.12'
    wheel == 0.45.1; python_version >= '3.12'
  PIP_REQUIREMENTS: |
    # This is a pip requirements file. For documentation see:
    # https://pip.pypa.io/en/stable/reference/requirements-file-format/
    # For valid environment markers (after the ';'), see:
    # https://peps.python.org/pep-0508/#environment-markers

    ipykernel == 5.1.0; python_version < '3.11'
    ipykernel == 6.29.1; python_version == '3.11'
    ipykernel == 6.29.5; python_version >= '3.12'
    ipython == 7.4.0; python_version < '3.11'
    ipython == 8.21.0; python_version == '3.11'
    ipython == 8.30.0; python_version >= '3.12'
    ipywidgets == 7.4.2; python_version < '3.11'
    ipywidgets == 8.1.1; python_version == '3.11'
    ipywidgets == 8.1.5; python_version >= '3.12'
    metakernel == 0.20.14; python_version < '3.11'
    metakernel == 0.30.2; python_version >= '3.11'
    notebook == 5.7.8; python_version < '3.11'
    notebook == 7.3.1; python_version >= '3.11'
    scons == 4.1.0; python_version < '3.11'
    scons == 4.8.1; python_version >= '3.11'

    requests == 2.27.1; python_version < '3.11'
    requests == 2.32.3; python_version >= '3.11'
    PyYAML == 6.0.2
    uproot == 5.5.1

    # Mock is included in the Python standard library as unittest.mock from
    # 3.3 onwards.
    mock == 2.0.0; python_version < '3.3'
    responses == 0.25.3

    psutil == 5.8.0; python_version < '3.10'
    psutil == 5.9.0; python_version == '3.10'
    psutil == 6.1.0; python_version >= '3.11'

    numpy == 1.16.2; python_version < '3.8'
    numpy == 1.19.5; python_version == '3.8'
    numpy == 1.23.4; python_version >= '3.9' and python_version <= '3.10'
    numpy == 1.23.5; python_version == '3.11'
    numpy == 1.26.4; python_version >= '3.12'

    scipy == 1.2.1; python_version < '3.8'
    scipy == 1.6.1; python_version == '3.8'
    scipy == 1.9.3; python_version >= '3.9' and python_version <= '3.10'
    scipy == 1.10.1; python_version == '3.11'
    scipy == 1.14.1; python_version == '3.12'
    scipy; python_version >= '3.13'

    Cython == 0.29.16; python_version < '3.8'
    Cython == 0.29.21; python_version >= '3.8' and python_version <= '3.11'
    Cython == 3.0.11; python_version >= '3.12'

    seaborn == 0.9.0; python_version < '3.9'
    seaborn == 0.13.2; python_version >= '3.9'

    scikit-learn == 0.20.3; python_version < '3.8'
    scikit-learn == 0.24.1; python_version >= '3.8' and python_version < '3.11'
    scikit-learn == 1.3.0; python_version == '3.11'
    scikit-learn == 1.6.0; python_version >= '3.12'

    sklearn-evaluation == 0.4; python_version < '3.9'
    sklearn-evaluation == 0.5.2; python_version == '3.9'
    sklearn-evaluation == 0.8.1; python_version == '3.10'
    sklearn-evaluation == 0.12.0; python_version == '3.11'
    sklearn-evaluation == 0.12.2; python_version >= '3.12'

    Keras == 2.2.4; python_version < '3.8'
    Keras == 2.4.3; python_version == '3.8'
    Keras == 2.13.1; python_version >= '3.9' and python_version <= '3.11'
    Keras == 3.7.0; python_version >= '3.12'

    tensorflow == 1.13.1; python_version < '3.8'
    tensorflow == 2.4.1; python_version == '3.8'
    tensorflow == 2.13.1; python_version >= '3.9' and python_version <= '3.11'
    tensorflow == 2.16.2; python_version >= '3.12'

    # See version compatibility table at https://pypi.org/project/tensorflow-metal/
    # only for Mac with Apple silicon or AMD GPUs
    # tensorflow-metal == 1.0.0; sys_platform == 'darwin' and python_version == '3.11'

    xgboost == 0.82; python_version < '3.8'
    xgboost == 1.3.3; python_version == '3.8'
    xgboost == 1.2.0; python_version >= '3.9' and python_version < '3.11'
    xgboost == 1.7.5; python_version == '3.11'
    xgboost == 2.1.3; python_version >= '3.12'

    dryable == 1.0.3; python_version < '3.9'
    dryable == 1.0.5; python_version >= '3.9' and python_version <= '3.11'
    dryable == 1.2.0; python_version >= '3.12'

    pandas == 0.24.2; python_version < '3.8'
    pandas == 1.2.3; python_version == '3.8'
    pandas == 1.5.3; python_version >= '3.9' and python_version <= '3.11'
    pandas == 2.2.3; python_version == '3.12'
    pandas; python_version >= '3.13'

    dask[array,dataframe,distributed] == 2023.2.0; python_version < '3.11'
    dask[array,dataframe,distributed] == 2024.11.2; python_version >= '3.11'
    dask_jobqueue == 0.8.2; python_version < '3.12'
    dask_jobqueue == 0.9.0; python_version >= '3.12'

    # readline is needed by alien.py (xjalienfs)
    gnureadline

build_requires:
  - alibuild-recipe-tools
---
#!/bin/bash -e
mkdir -p "$INSTALLROOT/etc/modulefiles"
alibuild-generate-module > "$INSTALLROOT/etc/modulefiles/$PKGNAME"
