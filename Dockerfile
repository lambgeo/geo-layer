ARG VERSION
ARG RUNTIME

FROM lambgeo/lambda-gdal:${VERSION}-${RUNTIME}

ARG VERSION
ENV VERSION $VERSION

COPY requirements-gdal${VERSION}.txt requirements.txt
RUN pip install -r requirements.txt --no-cache-dir --no-binary :all: -t $PREFIX/python
RUN rm requirements.txt

ENV PYTHONPATH=$PYTHONPATH:$PREFIX/python
