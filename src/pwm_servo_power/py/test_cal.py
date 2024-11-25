import pygame
from data_loader import CoordinateDataLoader
from polynomial_model import PolynomialModel
import numpy as np
import os
def read_coordinates_with_features(file_path):
    """读取文件中的坐标数据及特征并返回坐标列表"""
    data_loader = CoordinateDataLoader(file_path)
    data_loader.load_data()
    data = data_loader.get_data()
    coordinates = []
    for item in data:
        frame_x, frame_y = item['frame_position']
        x1 = item['x1']
        y1 = item['y1']
        x2 = item['x2']
        y2 = item['y2']
        left1 = item['left1']
        right1 = item['right1']
        up1 = item['up1']
        down1 = item['down1']
        left2 = item['left2']
        right2 = item['right2']
        up2 = item['up2']
        down2 = item['down2']
        coordinates.append([
            frame_x, frame_y,  # 原始帧坐标
            x1, y1, x2, y2,   # 其他特征
            left1, right1, up1, down1,
            left2, right2, up2, down2
        ])
    return coordinates

def write_predicted_coordinates_txt(output_file, original_coords, predicted_coords):
    """将原始坐标与预测坐标写入普通文本文件"""
    try:
        with open(output_file, 'w') as file:
            # 写入表头（可选）
            file.write("frame_x, frame_y -> output_x, output_y\n")
            # 写入每一行数据
            for original, predicted in zip(original_coords, predicted_coords):
                frame_x, frame_y = original
                output_x, output_y = predicted
                line = f"{frame_x}, {frame_y} -> {output_x}, {output_y}\n"
                file.write(line)
        print(f"Predicted coordinates successfully written to {output_file}")
    except Exception as e:
        print(f"Error writing to {output_file}: {e}")

def main():
    # 初始化Pygame
    pygame.init()
    infoObject = pygame.display.Info()
    WINDOW_WIDTH, WINDOW_HEIGHT = infoObject.current_w, infoObject.current_h
    screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.FULLSCREEN)
    pygame.display.set_caption("FPGA Point Display")

    # 读取所有坐标及特征
    coordinates_with_features = read_coordinates_with_features("coordinates_log.txt")

    # 实例化模型
    model = PolynomialModel()

    # 计算预测坐标
    predicted_coordinates = []
    for item in coordinates_with_features:
        frame_x, frame_y, x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2 = item
        output_0, output_1 = model.calculate_outputs(
            x1, y1, x2, y2,
            left1, right1, up1, down1,
            left2, right2, up2, down2
        )
        predicted_coordinates.append([output_0, output_1])

    # 将坐标转换为整数并确保在屏幕范围内
    def clamp(value, min_value, max_value):
        return max(min_value, min(value, max_value))

    original_scaled = []
    for coord in coordinates_with_features:
        frame_x, frame_y = coord[0], coord[1]
        x = int(frame_x)
        y = int(frame_y)
        # 可选：翻转y轴，如果需要的话
        y = WINDOW_HEIGHT - y
        # 确保坐标在屏幕范围内
        x = clamp(x, 0, WINDOW_WIDTH - 1)
        y = clamp(y, 0, WINDOW_HEIGHT - 1)
        original_scaled.append((x, y))

    predicted_scaled = []
    for coord in predicted_coordinates:
        x_pred, y_pred = coord
        x = int(x_pred)
        y = int(y_pred)
        # 可选：翻转y轴，如果需要的话
        y = WINDOW_HEIGHT - y
        # 确保坐标在屏幕范围内
        x = clamp(x, 0, WINDOW_WIDTH - 1)
        y = clamp(y, 0, WINDOW_HEIGHT - 1)
        predicted_scaled.append((x, y))

    # 写入预测坐标到txt文件
    output_file = "predicted_coordinates.txt"
    # 确保输出目录存在（可选）
    output_dir = os.path.dirname(output_file)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    # 准备原始和预测坐标用于写入
    original_coords_for_write = [(coord[0], coord[1]) for coord in coordinates_with_features]
    predicted_coords_for_write = [(coord[0], coord[1]) for coord in predicted_coordinates]
    write_predicted_coordinates_txt(output_file, original_coords_for_write, predicted_coords_for_write)

    # 主循环
    running = True
    clock = pygame.time.Clock()  # 控制帧率

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            # 添加按键监听以退出全屏
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    running = False

        screen.fill((0, 0, 0))  # 黑色背景

        # 绘制原始帧坐标（红色）
        for pos in original_scaled:
            pygame.draw.circle(screen, (255, 0, 0), pos, 3)

        # 绘制预测坐标（绿色）
        for pos in predicted_scaled:
            pygame.draw.circle(screen, (0, 255, 0), pos, 3)

        # 添加图例
        font = pygame.font.SysFont(None, 24)
        red_text = font.render("Frame Points", True, (255, 0, 0))
        green_text = font.render("Predicted Points", True, (0, 255, 0))
        screen.blit(red_text, (10, 10))
        screen.blit(green_text, (10, 30))

        pygame.display.flip()
        clock.tick(60)  # 限制帧率为60FPS

    pygame.quit()

if __name__ == "__main__":
    main()
def read_coordinates_with_features(file_path):
    """读取文件中的坐标数据及特征并返回坐标列表"""
    data_loader = CoordinateDataLoader(file_path)
    data_loader.load_data()
    data = data_loader.get_data()
    coordinates = []
    for item in data:
        frame_x, frame_y = item['frame_position']
        x1 = item['x1']
        y1 = item['y1']
        x2 = item['x2']
        y2 = item['y2']
        left1 = item['left1']
        right1 = item['right1']
        up1 = item['up1']
        down1 = item['down1']
        left2 = item['left2']
        right2 = item['right2']
        up2 = item['up2']
        down2 = item['down2']
        coordinates.append([
            frame_x, frame_y,  # 原始帧坐标
            x1, y1, x2, y2,   # 其他特征
            left1, right1, up1, down1,
            left2, right2, up2, down2
        ])
    return coordinates

def main():
    # 初始化Pygame
    pygame.init()
    infoObject = pygame.display.Info()
    WINDOW_WIDTH, WINDOW_HEIGHT = infoObject.current_w, infoObject.current_h
    screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.FULLSCREEN)
    pygame.display.set_caption("FPGA Point Display")

    # 读取所有坐标及特征
    coordinates_with_features = read_coordinates_with_features("coordinates_log.txt")

    # 实例化模型
    model = PolynomialModel()

    # 计算预测坐标
    predicted_coordinates = []
    for item in coordinates_with_features:
        frame_x, frame_y, x1, y1, x2, y2, left1, right1, up1, down1, left2, right2, up2, down2 = item
        output_0, output_1 = model.calculate_outputs(
            x1, y1, x2, y2,
            left1, right1, up1, down1,
            left2, right2, up2, down2
        )
        predicted_coordinates.append([output_0, output_1])

    # 将坐标转换为整数并确保在屏幕范围内
    def clamp(value, min_value, max_value):
        return max(min_value, min(value, max_value))

    original_scaled = []
    for coord in coordinates_with_features:
        frame_x, frame_y = coord[0], coord[1]
        x = int(frame_x)
        y = int(frame_y)
        # 可选：翻转y轴，如果需要的话
        y = WINDOW_HEIGHT - y
        # 确保坐标在屏幕范围内
        x = clamp(x, 0, WINDOW_WIDTH - 1)
        y = clamp(y, 0, WINDOW_HEIGHT - 1)
        original_scaled.append((x, y))

    predicted_scaled = []
    for coord in predicted_coordinates:
        x_pred, y_pred = coord
        x = int(x_pred)
        y = int(y_pred)
        # 可选：翻转y轴，如果需要的话
        y = WINDOW_HEIGHT - y
        # 确保坐标在屏幕范围内
        x = clamp(x, 0, WINDOW_WIDTH - 1)
        y = clamp(y, 0, WINDOW_HEIGHT - 1)
        predicted_scaled.append((x, y))

    # 主循环
    running = True
    clock = pygame.time.Clock()  # 控制帧率

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            # 添加按键监听以退出全屏
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    running = False

        screen.fill((0, 0, 0))  # 黑色背景

        # 绘制原始帧坐标（红色）
        for pos in original_scaled:
            pygame.draw.circle(screen, (255, 0, 0), pos, 3)

        # 绘制预测坐标（绿色）
        for pos in predicted_scaled:
            pygame.draw.circle(screen, (0, 255, 0), pos, 3)

        # 添加图例
        font = pygame.font.SysFont(None, 24)
        red_text = font.render("Frame Points", True, (255, 0, 0))
        green_text = font.render("Predicted Points", True, (0, 255, 0))
        screen.blit(red_text, (10, 10))
        screen.blit(green_text, (10, 30))

        pygame.display.flip()
        clock.tick(60)  # 限制帧率为60FPS

    pygame.quit()

if __name__ == "__main__":
    main()