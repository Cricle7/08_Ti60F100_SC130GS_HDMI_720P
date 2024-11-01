import pygame
from data_loader import CoordinateDataLoader
import numpy as np

# 设置窗口大小
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720

# 初始化pygame
pygame.init()
screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
pygame.display.set_caption("Points from coordinates_log.txt")

# 打开并读取coordinates_log.txt文件
def read_coordinates(file_path):
    """读取文件中的坐标数据并返回坐标列表"""
    data_loader = CoordinateDataLoader(file_path)
    data_loader.load_data()
    data = data_loader.get_data()
    coordinates = []
    # with open(file_path, "r") as f:
        # for line in f:
            # # 解析坐标
            # parts = line.strip().split(',')
            # x1 = int(parts[0].split(': ')[1])
            # y1 = int(parts[1].split(': ')[1])
            # x2 = int(parts[2].split(': ')[1])
            # y2 = int(parts[3].split(': ')[1])
            # coordinates.append(((x1, y1), (x2, y2)))
    for item in data:
        x1 = item['x1']
        y1 = item['y1']
        x2 = item['x2']
        y2 = item['y2']
        frame_position = item['frame_position']
        coordinates.append([x1, y1, x2, y2])

    # coordinates = np.array(coordinates, dtype=np.float32)
    return coordinates

# 读取所有坐标
coordinates = read_coordinates("coordinates_log.txt")

running = True
while running:
    screen.fill((0, 0, 0))  # 黑色背景
    
    # 检查事件
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
    
    # 绘制所有点
    for [x1, y1 ,x2, y2] in coordinates:
        pygame.draw.circle(screen, (255, 0, 0), (x1, y1), 5)  # 红色点，x1, y1
        pygame.draw.circle(screen, (0, 0, 255), (x2, y2), 5)  # 蓝色点，x2, y2
    
    # 更新显示
    pygame.display.flip()

# 关闭pygame
pygame.quit()
