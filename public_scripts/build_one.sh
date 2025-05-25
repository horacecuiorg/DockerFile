#!/usr/bin/env bash
set -e

dir="$1"
platforms="${2:-linux/amd64,linux/arm64}"

for file in "$dir"/Dockerfile*; do
  [ -f "$file" ] || continue
  base=$(basename "$file")
  service=$(basename "$dir")

  if [[ "$base" == "Dockerfile" ]]; then
    tag="latest"
  else
    tag="${base#Dockerfile_}"
  fi

  image_dockerhub="${DOCKER_NAMESPACE}/${service}:${tag}"
  image_ghcr="ghcr.io/${GHCR_ORG_NAMESPACE}/${service}:${tag}"

  echo "📦 Building $service:$tag from $file..."
  docker buildx build \
    --file "$file" \
    --platform "$platforms" \
    --cache-from type=gha,scope=$service \
    --cache-to type=gha,mode=max,scope=$service \
    --progress=plain \
    --push \
    -t "$image_dockerhub" \
    -t "$image_ghcr" \
    "$dir"

  echo "$image_dockerhub" >> images.txt
  echo "$image_ghcr" >> images.txt
done
