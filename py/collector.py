import pygame
import sys
import time
from serial_receiver import SerialReceiver

# 设置串口和窗口参数
SERIAL_PORT = 'COM22'  # 修改为你的串口
BAUD_RATE = 115200    # 修改为你的波特率

# 初始化串口接收器
try:
    receiver = SerialReceiver(SERIAL_PORT, BAUD_RATE)
except Exception as e:
    print(f"Error initializing SerialReceiver: {e}")
    sys.exit(1)

# 初始化 pygame
pygame.init()
infoObject = pygame.display.Info()
WINDOW_WIDTH, WINDOW_HEIGHT = infoObject.current_w, infoObject.current_h
screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.FULLSCREEN)
pygame.display.set_caption("FPGA Point Display")

# 定义矩形框参数
FRAME_SIZE = 40
FRAME_COLOR = (0, 255, 0)  # 绿色
FRAME_POSITIONS = []  # 存储所有矩形框的位置

# 生成矩形框的所有位置（从左到右，从上到下，每次移动40像素）
for y in range(0, WINDOW_HEIGHT, FRAME_SIZE):
    for x in range(0, WINDOW_WIDTH, FRAME_SIZE):
        FRAME_POSITIONS.append((x, y))

# 打开文件以追加方式记录坐标
try:
    log_file = open("coordinates_log.txt", "w")  # 使用 'w' 模式，每次运行程序都清空文件
except IOError as e:
    print(f"无法打开文件 coordinates_log.txt: {e}")
    receiver.close()
    pygame.quit()
    sys.exit(1)

# 主循环
running = True
current_frame_index = 0  # 当前矩形框的位置索引

while running and current_frame_index < len(FRAME_POSITIONS):
    frame_x, frame_y = FRAME_POSITIONS[current_frame_index]
    FRAME_RECT = pygame.Rect(frame_x, frame_y, FRAME_SIZE, FRAME_SIZE)

    # 停留开始时间
    start_time = time.time()
    while time.time() - start_time < 30:  # 停留30秒
        # 填充黑色背景
        screen.fill((0, 0, 0))

        # 绘制当前的矩形框
        pygame.draw.rect(screen, FRAME_COLOR, FRAME_RECT, 2)  # 线宽为 2

        # 检查事件
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
                break
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    running = False
                    break

        if not running:
            break

        # 接收串口数据
        coordinates = receiver.read_packet()
        if coordinates:
            (x1, y1), (x2, y2) = coordinates

            # 将坐标写入文件，包含当前矩形框的位置
            try:
                log_file.write(f"Frame Position: ({frame_x}, {frame_y}), x1: {x1}, y1: {y1}, x2: {x2}, y2: {y2}\n")
                log_file.flush()  # 刷新缓冲区，确保数据写入文件
            except IOError as e:
                print(f"文件写入错误: {e}")

            # 绘制接收到的点
            if 0 <= x1 < WINDOW_WIDTH and 0 <= y1 < WINDOW_HEIGHT:
                pygame.draw.circle(screen, (255, 0, 0), (x1, y1), 5)  # 红色点
            if 0 <= x2 < WINDOW_WIDTH and 0 <= y2 < WINDOW_HEIGHT:
                pygame.draw.circle(screen, (0, 0, 255), (x2, y2), 5)  # 蓝色点

        # 更新显示
        pygame.display.flip()

    # 移动到下一个矩形框位置
    current_frame_index += 1

# 关闭串口、文件和 pygame
receiver.close()
log_file.close()
pygame.quit()
