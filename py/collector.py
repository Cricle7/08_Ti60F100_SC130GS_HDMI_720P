import pygame
import sys
from serial_receiver import SerialReceiver

# 设置串口和窗口参数
SERIAL_PORT = 'COM22'  # 修改为你的串口
BAUD_RATE = 115200    # 修改为你的波特率

# 初始化串口接收器
try:
    receiver = SerialReceiver(SERIAL_PORT, BAUD_RATE)
except Exception as e:
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
FRAME_RECT = pygame.Rect(10, 10, FRAME_SIZE, FRAME_SIZE)  # 左上角偏移 10 像素

# 打开文件以追加方式记录坐标
try:
    log_file = open("coordinates_log.txt", "w")
except IOError as e:
    print(f"无法打开文件 coordinates_log.txt: {e}")
    receiver.close()
    pygame.quit()
    sys.exit(1)

running = True

while running:
    # 填充黑色背景
    screen.fill((0, 0, 0))

    # 绘制左上角的矩形框
    pygame.draw.rect(screen, FRAME_COLOR, FRAME_RECT, 2)  # 线宽为 2

    # 检查事件
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                running = False

    # 接收串口数据
    coordinates = receiver.read_packet()
    if coordinates:
        (x1, y1), (x2, y2) = coordinates

        # 将坐标写入文件并绘制
        try:
            log_file.write(f"x1: {x1}, y1: {y1}, x2: {x2}, y2: {y2}\n")
        except IOError as e:
            print(f"文件写入错误: {e}")

        # 确保坐标在屏幕范围内
        if 0 <= x1 < WINDOW_WIDTH and 0 <= y1 < WINDOW_HEIGHT:
            pygame.draw.circle(screen, (255, 0, 0), (x1, y1), 5)  # 红色点
        if 0 <= x2 < WINDOW_WIDTH and 0 <= y2 < WINDOW_HEIGHT:
            pygame.draw.circle(screen, (0, 0, 255), (x2, y2), 5)  # 蓝色点

    # 更新显示
    pygame.display.flip()

# 关闭串口、文件和 pygame
receiver.close()
log_file.close()
pygame.quit()
