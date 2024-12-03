# 使用 ROS 2 Humble 的核心映像作為基礎
FROM ros:humble-ros-core-jammy

# 更新系統和安裝必要的工具
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-pip \
    python3-colcon-common-extensions \
    git \
    && rm -rf /var/lib/apt/lists/*

# 設定工作目錄
WORKDIR /root/ros2_ws

# 複製 entrypoint 並使其可執行
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 設置入口點
ENTRYPOINT ["/entrypoint.sh"]

# 預設執行 bash
CMD ["bash"]
