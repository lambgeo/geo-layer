# geo-layer

[![CircleCI](https://circleci.com/gh/lambgeo/geo-layer.svg?style=svg)](https://circleci.com/gh/lambgeo/geo-layer)

#### Python package

```
numpy
pygeos
shapely
rasterio>=1.1.3
pyproj==2.4.1 (only with GDAL >=3.0)
mercantile
supermercado
```

#### Arns

`arn:aws:lambda:{REGION}:524387336408:layer:gdal{GDAL_VERSION_NODOT}-py{PYTHON_VERSION_NODOT}-geo:{LAYER_VERSION}`

#### Regions
- us-east-1
- us-east-2
- us-west-1
- us-west-2
- eu-central-1

#### versions:

gdal | version | size (Mb)| unzipped size (Mb)| arn
  ---|      ---|       ---|                ---| ---
3.1  |        1|          |                   | arn:aws:lambda:us-east-1:524387336408:layer:gdal31-py37-geo:1
3.0  |        1|          |                   | arn:aws:lambda:us-east-1:524387336408:layer:gdal30-py37-geo:1
2.4  |        1|      34.5|              114.9| arn:aws:lambda:us-east-1:524387336408:layer:gdal24-py37-geo:1
  ---|      ---|       ---|                ---| ---
3.1  |        1|          |                   | arn:aws:lambda:us-east-1:524387336408:layer:gdal31-py38-geo:1
3.0  |        1|          |                   | arn:aws:lambda:us-east-1:524387336408:layer:gdal30-py38-geo:1
2.4  |        1|      35.7|              128.8| arn:aws:lambda:us-east-1:524387336408:layer:gdal24-py38-geo:1

## How To

### Create package

#### Simple app (no dependency)

```bash
zip -r9q /tmp/package.zip handler.py
```

#### Complex (dependencies)

- Create a docker file
```dockerfile
FROM lambgeo/lambda:gdal3.0-py3.7-geo

ENV PYTHONUSERBASE=/var/task

# Install dependencies
COPY handler.py $PYTHONUSERBASE/handler.py
RUN pip install rio-tiler --user

RUN mv ${PYTHONUSERBASE}/lib/python3.7/site-packages/* ${PYTHONUSERBASE}/
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

### Create new lambda layer

```bash
docker build --tag package:latest . --build-arg GDAL_VERSION=2.4 --build-arg PYTHON_VERSION=3.7
docker run --name lambda -w /var/task -itd package:latest bash
docker cp scripts/create-lambda-layer.sh lambda:/create-lambda-layer.sh
docker exec -it lambda bash /create-lambda-layer.sh
docker cp lambda:/tmp/package.zip package.zip
docker stop lambda
docker rm lambda
```

### Publish layer

```bash
# cp package.zip gdal3.0-py3.7-geo.zip
cp package.zip gdal2.4-py3.7-geo.zip
# gdal version, python version, layer name
python scripts/deploy-layer.py "2.4" "3.7"  "geo"
```

List ARNs

```bash
python scripts/list_layers.py > arns.json
```
