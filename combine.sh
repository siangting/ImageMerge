#!/bin/bash

# 檢查參數數量
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <path_to_dockerfile1> <path_to_dockerfile2> <output_dockerfile>"
    exit 1
fi

# 取得輸入參數
DOCKERFILE1=$1
DOCKERFILE2=$2
OUTPUT_DOCKERFILE=$3

# 檢查第一個 Dockerfile 是否存在
if [ ! -f "$DOCKERFILE1" ]; then
    echo "Error: $DOCKERFILE1 does not exist."
    exit 1
fi

# 檢查第二個 Dockerfile 是否存在
if [ ! -f "$DOCKERFILE2" ]; then
    echo "Error: $DOCKERFILE2 does not exist."
    exit 1
fi

# 開始合併
echo "Merging $DOCKERFILE1 and $DOCKERFILE2 into $OUTPUT_DOCKERFILE..."

# 建立新 Dockerfile 並添加多階段構建邏輯
{
    echo "# Merged Dockerfile"
    echo ""
    echo "# Stage 1: From $DOCKERFILE1"
    sed 's/^FROM /FROM /' "$DOCKERFILE1"
    echo ""
    echo "# Stage 2: From $DOCKERFILE2"
    sed 's/^FROM /FROM /' "$DOCKERFILE2"
    echo ""
    echo "# Final Stage: Combine builds"
    echo "FROM $(awk '/^FROM/ {print $2; exit}' $DOCKERFILE2) AS final"
    echo "COPY --from=0 / /"  # 從第一階段複製所有內容
    echo "COPY --from=1 / /"  # 從第二階段複製所有內容
} > "$OUTPUT_DOCKERFILE"

echo "Merged Dockerfile with multi-stage builds created at $OUTPUT_DOCKERFILE"
