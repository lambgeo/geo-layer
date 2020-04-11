ARG GDAL_VERSION
ARG PYTHON_VERSION
FROM lambgeo/lambda:gdal${GDAL_VERSION}-py${PYTHON_VERSION}

ARG GDAL_VERSION
ENV GDAL_VERSION $GDAL_VERSION

RUN pip install cython==0.28 --no-cache-dir

COPY requirements-gdal${GDAL_VERSION}.txt requirements.txt
RUN pip install -r requirements.txt --no-cache-dir --no-binary :all: -t $PREFIX/python
RUN rm requirements.txt

ENV PYTHONPATH=$PYTHONPATH:$PREFIX/python
