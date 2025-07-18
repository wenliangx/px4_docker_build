#!/bin/bash

set -e

PX4_VERSION=$1
PX4_TARGET=$2

if [ -z "$PX4_VERSION" ] || [ -z "$PX4_TARGET" ]; then
  echo "用法: ./build_px4.sh <px4_version> <build_target>"
  echo "示例: ./build_px4.sh v1.14.0 px4_sitl_default"
  exit 1
fi

IMAGE_NAME="px4:$PX4_VERSION"
CONTAINER_NAME="px4_build_temp_$PX4_VERSION"

if ! docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
  echo "[*] 镜像 $IMAGE_NAME 不存在，正在构建..."
  docker build \
    --build-arg PX4_VERSION=$PX4_VERSION \
    -t $IMAGE_NAME \
    .
else
  echo "[*] 镜像 $IMAGE_NAME 已存在，跳过构建"
fi

LOCAL_PX4_DIR="$(pwd)/px4-$PX4_VERSION-$PX4_TARGET"


echo "[*] 正在运行构建容器..."
docker run \
  --name $CONTAINER_NAME \
  $IMAGE_NAME /bin/bash -c "make $PX4_TARGET -j$(nproc)"


docker cp $CONTAINER_NAME:/opt/PX4-Autopilot $LOCAL_PX4_DIR

docker rm $CONTAINER_NAME

echo "[✅] 编译产物在: $LOCAL_PX4_DIR/build/$PX4_TARGET/"


docker rm $CONTAINER_NAME > /dev/null
