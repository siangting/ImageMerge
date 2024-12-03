# 基於官方 Python 3.8 映像
FROM python:3.8-slim

# 安裝必要的系統工具
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安裝 gymize 和相關依賴
RUN pip install gymize

# 安裝 Unity 專案所需的 git 依賴
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev

RUN pip install --upgrade pip && \
    pip install gymnasium gymize pettingzoo ffmpeg

# 複製本地專案到容器中
WORKDIR /gymize
COPY . .

# 安裝 Unity 所需的其他工具或插件
# 如果有需要 Unity 安裝的步驟，可以在這裡添加命令

# 指定容器啟動時運行的命令
CMD ["bash"]
