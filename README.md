# GDAL based AWS Lambda Layers

<p align="center">
  <img src="https://user-images.githubusercontent.com/10407788/95621320-7b226080-0a3f-11eb-8194-4b55a5555836.png" style="max-width: 800px;" alt="geo-layer"></a>
</p>
<p align="center">
  <em>AWS lambda (Amazonlinux) Layers and Docker images.</em>
</p>
<p align="center">
  <a href="https://github.com/lambgeo/geo-layer/actions?query=workflow%3ACI" target="_blank">
      <img src="https://github.com/lambgeo/geo-layer/workflows/CI/badge.svg" alt="Test">
  </a>
</p>

## Python package

```
numpy

pygeos==0.8
shapely==1.7.1
rasterio==1.1.8

pyproj==2.4.1  # Only for GDAL>=3.1

mercantile==1.1.6
supermercado==0.2.0

# HACK, those package are in the docker image but not in the lambda env
requests
pyyaml

```


## Available layers

gdal | version | size (Mb)| unzipped size (Mb)| arn
  ---|      ---|       ---|                ---| ---
3.2  |        1|      43.8|              138.8| arn:aws:lambda:{REGION}:524387336408:layer:gdal32-py37-geo:1
3.1  |        1|      43.7|              128.4| arn:aws:lambda:{REGION}:524387336408:layer:gdal31-py37-geo:1
2.4  |        1|      36.3|              121.3| arn:aws:lambda:{REGION}:524387336408:layer:gdal24-py37-geo:1
  ---|      ---|       ---|                ---| ---
3.2  |        1|      44.4|                140| arn:aws:lambda:{REGION}:524387336408:layer:gdal32-py38-geo:1
3.1  |        1|      44.3|              139.7| arn:aws:lambda:{REGION}:524387336408:layer:gdal31-py38-geo:1
2.4  |        1|      36.7|                130| arn:aws:lambda:{REGION}:524387336408:layer:gdal24-py38-geo:1

### Arns format

- `arn:aws:lambda:${region}:524387336408:layer:gdal(24|31|32)-python(37|38)-geo:${version}`

### Regions
- ap-northeast-1
- ap-northeast-2
- ap-south-1
- ap-southeast-1
- ap-southeast-2
- ca-central-1
- eu-central-1
- eu-north-1
- eu-west-1
- eu-west-2
- eu-west-3
- sa-east-1
- us-east-1
- us-east-2
- us-west-1
- us-west-2

### Layer content

```
layer.zip
  |
  |___ bin/      # Binaries
  |___ lib/      # Shared libraries (GDAL, PROJ, GEOS...)
  |___ share/    # GDAL/PROJ data directories
  |___ python/   # Python modules
```

The layer content will be unzip in `/opt` directory in AWS Lambda. For the python libs to be able to use the C libraries you have to make sure to set 2 important environment variables:

- **GDAL_DATA:** /opt/share/gdal
- **PROJ_LIB:** /opt/share/proj

# How To

There are 2 ways to use the layers:

## 1. Simple (No dependencies)

If you don't need to add more python module (dependencies), you can just create a lambda package (zip file) with you lambda handler.

```bash
zip -r9q package.zip handler.py
```

**Content:**

```
package.zip
  |___ handler.py   # aws lambda python handler
```

**AWS Lambda Config:**
- arn: `arn:aws:lambda:us-east-1:524387336408:layer:gdal32-python38-geo:1` (example)
- env:
  - **GDAL_DATA:** /opt/share/gdal
  - **PROJ_LIB:** /opt/share/proj
- lambda handler: `handler.handler`


## 2. Advanced (need other python dependencies)

If your lambda handler needs more dependencies you'll have to use the exact same environment. To ease this you can find the docker images for each lambda on docker hub.

- Create a docker file

```dockerfile
FROM lambgeo/lambda-gdal:3.2-python3.8-geo

ENV PYTHONUSERBASE=/var/task

# Install dependencies
COPY handler.py $PYTHONUSERBASE/handler.py

# Here we use the `--user` option to make sure to not replicate modules.
RUN pip install rio-tiler --user

# Move some files around
RUN mv ${PYTHONUSERBASE}/lib/python3.8/site-packages/* ${PYTHONUSERBASE}/
RUN rm -rf ${PYTHONUSERBASE}/lib

echo "Create archive"
RUN cd $PYTHONUSERBASE && zip -r9q /tmp/package.zip *
```

- create package
```bash
docker build --tag package:latest .
docker run --name lambda -w /var/task -itd package:latest bash
docker cp lambda:/tmp/package.zip package.zip
docker stop lambda
docker rm lambda
```

**Content:**

```
package.zip
  |___ handler.py   # aws lambda python handler
  |___ module1/     # dependencies
  |___ module2/
  |___ module3/
  |___ ...
```

**AWS Lambda Config:**
- arn: `arn:aws:lambda:us-east-1:524387336408:layer:gdal32-python38-geo:1` (example)
- env:
  - **GDAL_DATA:** /opt/share/gdal
  - **PROJ_LIB:** /opt/share/proj
- lambda handler: `handler.handler`

### Refactor

We recently refactored the repo, to see old documentation please refer to https://github.com/lambgeo/geo-layer/tree/60c9cf69a4529e14d4394a0a3e78dd5f84d9e6ec
