#!/bin/bash

# 檢查參數數量是否足夠
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <number_of_dockerfiles> <output_dockerfile> <path_to_dockerfile1> [path_to_dockerfile2] ..."
    exit 1
fi

# 取得輸入參數
NUM_DOCKERFILES=$1
OUTPUT_DOCKERFILE=$2
shift 2  # 移除前兩個參數，剩下的都是 Dockerfile 路徑
DOCKERFILES=("$@")

# 確認輸入的數量與實際提供的 Dockerfile 路徑是否匹配
if [ "${#DOCKERFILES[@]}" -ne "$NUM_DOCKERFILES" ]; then
    echo "Error: Expected $NUM_DOCKERFILES Dockerfile paths, but got ${#DOCKERFILES[@]}."
    exit 1
fi

# 檢查每個 Dockerfile 是否存在
for DOCKERFILE in "${DOCKERFILES[@]}"; do
    if [ ! -f "$DOCKERFILE" ]; then
        echo "Error: $DOCKERFILE does not exist."
        exit 1
    fi
done

# 開始合併
echo "Merging ${DOCKERFILES[*]} into $OUTPUT_DOCKERFILE..."

# 建立新 Dockerfile 並添加多階段構建邏輯
{
    echo "# Merged Dockerfile"
    echo ""

    # 添加每個 Dockerfile 作為一個階段
    for i in "${!DOCKERFILES[@]}"; do
        DOCKERFILE=${DOCKERFILES[$i]}
        echo "# Stage $((i+1)) from $DOCKERFILE"

        # 確保第一行的 `FROM` 指令加上正確的 `AS stage_X`
        awk -v stage="stage_$i" '
            BEGIN { modified = 0 }
            /^FROM/ && modified == 0 { print $0 " AS " stage; modified = 1; next }
            { print $0 }
        ' "$DOCKERFILE"

        echo ""
    done

    # 添加最終階段
    echo "# Final Stage"
    echo "FROM ubuntu:20.04 AS final"
    echo "WORKDIR /merged"

    # 添加 COPY 指令從所有階段複製內容（特定目錄）
    for i in "${!DOCKERFILES[@]}"; do
        echo "# Copying specific directories from stage_$i"
        echo "COPY --from=stage_$i /etc /etc"
        echo "COPY --from=stage_$i /opt /opt"
        echo "COPY --from=stage_$i /var /var"
        echo "COPY --from=stage_$i /home /home"
    done

    # 添加環境設定或其他配置
    echo "ENV PATH=\$PATH:/opt/bin"
    echo "CMD [\"/bin/bash\"]"
} > "$OUTPUT_DOCKERFILE"

echo "Merged Dockerfile with $NUM_DOCKERFILES stages created at $OUTPUT_DOCKERFILE"
