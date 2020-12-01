
import json
from boto3.session import Session as boto3_session

AWS_REGIONS = [
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-south-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ca-central-1",
    "eu-central-1",
    "eu-north-1",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "sa-east-1",
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
]
layers = [
    "gdal24-python37-geo",
    "gdal31-python37-geo",
    "gdal32-python37-geo",
    "gdal24-python38-geo",
    "gdal31-python38-geo",
    "gdal32-python38-geo",
]


def main():
    results = []
    for region in AWS_REGIONS:
        res = {"region": region, "layers": []}

        session = boto3_session(region_name=region)
        client = session.client("lambda")
        for layer in layers:
            response = client.list_layer_versions(LayerName=layer)
            latest = response["LayerVersions"][0]
            res["layers"].append(dict(
                name=layer,
                arn=latest["LayerVersionArn"],
                version=latest["Version"]
            ))
        results.append(res)

    print(json.dumps(results))


if __name__ == '__main__':
    main()
