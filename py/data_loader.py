# data_loader.py

import re

class CoordinateDataLoader:
    def __init__(self, file_path):
        self.file_path = file_path
        self.data = []

    def load_data(self):
        pattern = re.compile(
                r"Frame Position: \((\d+), (\d+)\), "
                r"x1: (\d+), y1: (\d+), x2: (\d+), y2: (\d+), "
                r"left1: (\d+), right1: (\d+), up1: (\d+), down1: (\d+), "
                r"left2: (\d+), right2: (\d+), up2: (\d+), down2: (\d+), "
                r"sum: (\d+)"
            )

        with open(self.file_path, 'r') as file:
            for line in file:
                match = pattern.match(line.strip())
                if match:
                    frame_x = int(match.group(1))
                    frame_y = int(match.group(2))
                    x1 = int(match.group(3))
                    y1 = int(match.group(4))
                    x2 = int(match.group(5))
                    y2 = int(match.group(6))
                    left1 = int(match.group(7))
                    right1 = int(match.group(8))
                    up1 = int(match.group(9))
                    down1 = int(match.group(10))
                    left2 = int(match.group(11))
                    right2 = int(match.group(12))
                    up2 = int(match.group(13))
                    down2 = int(match.group(14))
                    sum_value = int(match.group(15))

                    self.data.append({
                        'frame_position': (frame_x, frame_y),
                        'x1': x1,
                        'y1': y1,
                        'x2': x2,
                        'y2': y2,
                        'left1': left1,
                        'right1': right1,
                        'up1': up1,
                        'down1': down1,
                        'left2': left2,
                        'right2': right2,
                        'up2': up2,
                        'down2': down2,
                        'sum': sum_value
                    })
                else:
                    print(f"无法解析的行: {line.strip()}")

    def get_data(self):
        """
        返回解析后的数据列表。
        """
        return self.data
