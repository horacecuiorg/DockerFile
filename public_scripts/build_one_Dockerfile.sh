#!/usr/bin/env bash
set -e

dir="$1"
platforms="${2:-linux/amd64,linux/arm64}"

[ -z "$dir" ] && echo "❌ Usage: $0 <dir> [platforms]" && exit 1

# 提取目录名
dirname=$(basename "$dir")

# 校验格式：只允许 a-z0-9.- 和最多一个 _
if ! [[ "$dirname" =~ ^[a-z0-9.-]+(_[a-z0-9.-]+)?$ ]]; then
  echo "❌ Invalid directory name '$dirname'. Must match: [a-z0-9.-]+(_[a-z0-9.-]+)?"
  exit 1
fi

# 解析 service 和 tag
if [[ "$dirname" == *_* ]]; then
  service="${dirname%%_*}"
  tag="${dirname#*_}"
else
  service="$dirname"
  tag="latest"
fi


# 镜像名
image_dockerhub="${DOCKER_NAMESPACE}/${service}:${tag}"
image_ghcr="ghcr.io/${GHCR_ORG_NAMESPACE}/${service}:${tag}"

echo "👉 Building $dirname => ${service}:${tag}" | tee -a images.txt

dockerfile="$dir/Dockerfile"
if [[ ! -f "$dockerfile" ]]; then
  echo "❌ Dockerfile not found in $dir"
  exit 1
fi

echo "📦 Building $service:$tag from $dockerfile..."
docker buildx build \
  --file "$dockerfile" \
  --platform "$platforms" \
  --cache-from type=gha,scope=$service \
  --cache-to type=gha,mode=max,scope=$service \
  --progress=plain \
  --push \
  -t "$image_dockerhub" \
  -t "$image_ghcr" \
  "$dir"

echo "📦 Built image: $image_dockerhub" | tee -a images.txt
echo "📦 Built image: $image_ghcr" | tee -a images.txt
