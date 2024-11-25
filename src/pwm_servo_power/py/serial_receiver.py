import serial
import struct

class SerialReceiver:
    def __init__(self, port, baud_rate):
        try:
            self.ser = serial.Serial(port, baud_rate, timeout=1)
            self.buffer = bytearray()
        except serial.SerialException as e:
            print(f"无法打开串口 {port}: {e}")
            raise

    def read_packet(self):
        """读取串口数据并解析，返回坐标信息"""
        if self.ser.in_waiting > 0:
            # 将接收的数据添加到缓冲区
            self.buffer.extend(self.ser.read(self.ser.in_waiting))

            # 检查缓冲区中是否存在完整的数据包
            while len(self.buffer) >= 22:
                # 检查头部是否为 0xFF, 0xFF
                if self.buffer[0] == 0xFF and self.buffer[1] == 0xFF:
                    # 提取一个完整的数据包
                    packet = self.buffer[:22]
                    self.buffer = self.buffer[22:]  # 移除已处理的数据

                    # 解析数据包
                    coordinates = self.parse_packet(packet)
                    if coordinates:
                        return coordinates
                else:
                    # 如果头部不匹配，则丢弃第一个字节继续检查
                    self.buffer.pop(0)
        return None

    def parse_packet(self, data):
        """解析数据包，返回坐标信息"""
        if len(data) == 22:
            try:
                # 解包数据
                header1, header2, *middle_data, tail1, tail2 = struct.unpack("!2B18B2B", data)

                # 检查头部和尾部是否正确
                if header1 == 0xFF and header2 == 0xFF and tail1 == 0x0D and tail2 == 0x0A:
                    # 将中间的 6 字节数据转换为二进制字符串
                    bit_string = ''.join(f'{byte:08b}' for byte in middle_data)

                    # 检查填充位是否正确
                    if (bit_string[0] != '0' or bit_string[12] != '0' or
                        bit_string[24:26] != '00' or bit_string[36:38] != '00'):
                        return None

                    # 解析坐标值
                    x1 = int(bit_string[1:12], 2)      # 第2位到第12位（11位）
                    x2 = int(bit_string[13:24], 2)     # 第14位到第24位（11位）
                    y1 = int(bit_string[26:36], 2)     # 第27位到第36位（10位）
                    y2 = int(bit_string[38:48], 2)     # 第39位到第48位（10位）
                    left1 = int(bit_string[49:60], 2)  # 第50位到第60位（11位）
                    right1 = int(bit_string[61:72], 2) # 第62位到第72位（11位）
                    up1 = int(bit_string[74:84], 2)    # 第75位到第84位（10位）
                    down1 = int(bit_string[86:96], 2)  # 第87位到第96位（10位）
                    left2 = int(bit_string[97:108], 2) # 第98位到第108位（11位）
                    right2 = int(bit_string[109:120], 2)# 第110位到第120位（11位）
                    up2 = int(bit_string[122:132], 2)  # 第123位到第132位（10位）
                    down2 = int(bit_string[134:144], 2)# 第135位到第144位（10位）

                    # 比较 x1 和 x2，将横坐标较小的点设为 (x1, y1)
                    if x2 < x1:
                        x1, y1, x2, y2 = x2, y2, x1, y1
                    if left2 < left1:
                        left1, right1, up1, down1, left2, right2, up2, down2= left2, right2, up2, down2, left1, right1, up1, down1
                    if any(v == 0 for v in [x1, x2, y1, y2, left1, right1, up1, down1, left2, right2, up2, down2]):
                        return None
                    if abs(y2-y1) > 400:
                        return None

                    return (x1, y1), (x2, y2), (left1, right1, up1, down1), (left1, right1, up1, down1)
                else:
                    return None
            except struct.error as e:
                print(f"数据包解包错误: {e}")
                return None
        else:
            return None

    def close(self):
        """关闭串口连接"""
        self.ser.close()
