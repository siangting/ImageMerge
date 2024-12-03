#!/bin/bash

# 檢查參數數量是否足夠
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <output_image_name:tag> <dockerfile_output> <image1> [image2 ... imageN]"
    exit 1
fi

# 取得輸入參數
OUTPUT_IMAGE=$1
DOCKERFILE_OUTPUT=$2
shift 2
IMAGES=("$@")

# 確認是否至少提供了一個源映像
if [ "${#IMAGES[@]}" -lt 1 ]; then
    echo "Error: At least one source image must be provided."
    exit 1
fi

# 創建合併的 Dockerfile
echo "Creating merged Dockerfile: $DOCKERFILE_OUTPUT..."

{
    echo "# Merged Dockerfile"
    echo ""
    
    # 為每個映像創建一個構建階段
    for i in "${!IMAGES[@]}"; do
        echo "# Stage $((i+1))"
        echo "FROM ${IMAGES[$i]} AS stage_$i"
        echo ""
    done

    # 定義最終階段
    echo "# Final Stage"
    echo "FROM ubuntu:20.04 AS final"
    echo "WORKDIR /merged"
    
    # 從每個階段複製內容到最終階段
    for i in "${!IMAGES[@]}"; do
        echo "COPY --from=stage_$i / /"
    done

    # 添加任何需要的後續操作
    echo "CMD [\"/bin/bash\"]"
} > "$DOCKERFILE_OUTPUT"

echo "Dockerfile saved at: $DOCKERFILE_OUTPUT"

# 使用生成的 Dockerfile 構建最終合併的映像
echo "Building merged image: $OUTPUT_IMAGE..."
docker build -t "$OUTPUT_IMAGE" -f "$DOCKERFILE_OUTPUT" .

echo "Merged image $OUTPUT_IMAGE has been built successfully."
