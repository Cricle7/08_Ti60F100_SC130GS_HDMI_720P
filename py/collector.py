import serial
import pygame
import struct

# 设置串口和窗口参数
SERIAL_PORT = 'COM22'  # 修改为你的串口
BAUD_RATE = 115200    # 修改为你的波特率
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
# 初始化串口
ser = serial.Serial(SERIAL_PORT, BAUD_RATE)

# 初始化 pygame
pygame.init()
#screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
#pygame.display.set_caption("FPGA Point Display")

# 打开文件以追加方式记录坐标
log_file = open("coordinates_log.txt", "a")

infoObject = pygame.display.Info()
WINDOW_WIDTH, WINDOW_HEIGHT = infoObject.current_w, infoObject.current_h
screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT), pygame.FULLSCREEN)
pygame.display.set_caption("FPGA Point Display")

# 定义矩形框参数
FRAME_SIZE = 40
FRAME_COLOR = (0, 255, 0)  # 绿色

FRAME_RECT = pygame.Rect(10, 10, FRAME_SIZE, FRAME_SIZE)  # 左上角偏移10像素
def get_coordinates(data):
    """解析 FPGA 数据并返回坐标"""
    if len(data) == 10:
        # 解包数据
        header1, header2, middle_data, tail1, tail2 = struct.unpack("!2B6s2B", data)
        
        # 检查头部和尾部是否正确
        if header1 == 0xFF and header2 == 0xFF and tail1 == 0x0D and tail2 == 0x0A:
            # 将中间的 6 字节数据转换为二进制字符串
            bit_string = ''.join(f'{byte:08b}' for byte in middle_data)
            
            # 检查填充位是否正确
            if (bit_string[0] != '0' or bit_string[12] != '0' or
                bit_string[24:26] != '00' or bit_string[36:38] != '00'):
                return None, None
            
            # 解析坐标值
            x1 = int(bit_string[1:12], 2)
            x2 = int(bit_string[13:24], 2)
            y1 = int(bit_string[26:36], 2)
            y2 = int(bit_string[38:48], 2)
            
            # 比较 x1 和 x2，将横坐标较小的点设为 (x1, y1)
            if x2 < x1:
                x1, y1, x2, y2 = x2, y2, x1, y1
            
            return (x1, y1), (x2, y2)
        else:
            return None, None
    else:
        return None, None

running = True
buffer = bytearray()  # 用于存储串口接收的字节

while running:
    screen.fill((0, 0, 0))  # 黑色背景

    # 检查事件
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # 接收串口数据
    if ser.in_waiting > 0:
        # 将接收的数据添加到缓冲区
        buffer.extend(ser.read(ser.in_waiting))

        # 检查缓冲区中是否存在完整的数据包
        while len(buffer) >= 10:
            # 检查头部是否为 0xFF, 0xFF
            if buffer[0] == 0xFF and buffer[1] == 0xFF:
                # 提取一个完整的数据包
                packet = buffer[:10]
                buffer = buffer[10:]  # 移除已处理的数据

                # 获取并处理坐标
                coordinates = get_coordinates(packet)
                if coordinates:
                    (x1, y1), (x2, y2) = coordinates

                    # 将坐标写入文件并绘制
                    log_file.write(f"x1: {x1}, y1: {y1}, x2: {x2}, y2: {y2}\n")
                    pygame.draw.circle(screen, (255, 0, 0), (x1, y1), 5)  # 红色点
                    pygame.draw.circle(screen, (0, 0, 255), (x2, y2), 5)  # 蓝色点
            else:
                # 如果头部不匹配，则丢弃第一个字节继续检查
                buffer.pop(0)

    # 更新显示
    pygame.display.flip()

# 关闭串口、文件和 pygame
ser.close()
log_file.close()
pygame.quit()
