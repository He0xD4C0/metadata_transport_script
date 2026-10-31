#!/bin/bash

# 设置安全选项
set -e  # 遇到错误立即退出
set -u  # 使用未初始化的变量时报错

# 检查是否安装了 exiftool
if ! command -v exiftool &> /dev/null; then
    echo "错误: 未找到 exiftool。请先安装它。"
    echo "在 macOS 上，你可以使用 'brew install exiftool' 安装。"
    echo "在 Ubuntu/Debian 上，可以使用 'sudo apt-get install libimage-exiftool-perl'。"
    exit 1
fi

# 设置 IFS（内部字段分隔符）为仅换行符，以便正确处理带空格的文件名
IFS=$'\n'

# 使用循环处理每个 .m2ts 文件
for m2ts_file in *.m2ts; do
    # 检查是否存在 .m2ts 文件，避免无匹配时的字面量扩展
    if [[ "$m2ts_file" == "*.m2ts" ]]; then
        echo "未找到 .m2ts 文件。"
        exit 1
    fi

    # 获取文件名（不含扩展名）
    base_name="${m2ts_file%.m2ts}"

    # 定义对应的 .mov 文件名
    mov_file="${base_name}.mov"

    # 检查对应的 .mov 文件是否存在
    if [[ ! -f "$mov_file" ]]; then
        echo "警告: 未找到与 '$m2ts_file' 对应的 '$mov_file'，跳过。"
        continue
    fi

    echo "正在处理: '$m2ts_file' -> '$mov_file'"

    # 使用 exiftool 复制所有元数据
    # -overwrite_original 选项直接修改文件而不保留备份，以节省空间。
    # 如果出于安全考虑希望保留备份，可以移除该选项。
    # -TagsFromFile 指示从源文件读取标签并写入当前处理的文件。
    exiftool -overwrite_original -TagsFromFile "$m2ts_file" "$mov_file"

    # 检查 exiftool 执行是否成功
    if [[ $? -eq 0 ]]; then
        echo "成功: '$mov_file' 的元数据已更新。"
    else
        echo "错误: 处理 '$mov_file' 时出现问题。"
    fi
done

echo "批量元数据转移完成。"