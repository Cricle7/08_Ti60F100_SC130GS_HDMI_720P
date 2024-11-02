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
            while len(self.buffer) >= 14:
                # 检查头部是否为 0xFF, 0xFF
                if self.buffer[0] == 0xFF and self.buffer[1] == 0xFF:
                    # 提取一个完整的数据包
                    packet = self.buffer[:14]
                    self.buffer = self.buffer[14:]  # 移除已处理的数据

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
        if len(data) == 14:
            try:
                # 解包数据
                header1, header2, *middle_data, tail1, tail2 = struct.unpack("!2B10B2B", data)

                # 检查头部和尾部是否正确
                if header1 == 0xFF and header2 == 0xFF and tail1 == 0x0D and tail2 == 0x0A:
                    # 将中间的 6 字节数据转换为二进制字符串
                    bit_string = ''.join(f'{byte:08b}' for byte in middle_data)

                    # 检查填充位是否正确
                    if (bit_string[0] != '0' or bit_string[12] != '0' or
                        bit_string[24:26] != '00' or bit_string[36:38] != '00'):
                        return None

                    # 解析坐标值
                    x1 = int(bit_string[1:12], 2)
                    x2 = int(bit_string[13:24], 2)
                    y1 = int(bit_string[26:36], 2)
                    y2 = int(bit_string[38:48], 2)
                    yb1 = int(bit_string[52:57], 2)
                    xb1 = int(bit_string[58:63], 2)
                    yb2 = int(bit_string[68:73], 2)
                    xb2 = int(bit_string[74:79], 2)
                    # 比较 x1 和 x2，将横坐标较小的点设为 (x1, y1)
                    if x2 < x1:
                        x1, y1, x2, y2 = x2, y2, x1, y1
                    if any(v == 0 for v in [x1, x2, y1, y2, yb1, xb1, yb2, xb2]):
                        return None
                    if abs(y2-y1) > 400:
                        return None

                    return (x1, y1), (x2, y2), (xb1, yb1), (xb2, yb2)
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
