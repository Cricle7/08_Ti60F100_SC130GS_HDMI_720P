# data_loader.py

import re

class CoordinateDataLoader:
    def __init__(self, file_path):
        self.file_path = file_path
        self.data = []

    def load_data(self):
        """
        从文件中加载数据，并解析成所需的格式。
        """
        pattern = re.compile(
            r"Frame Position: \((\d+), (\d+)\), x1: (\d+), y1: (\d+), x2: (\d+), y2: (\d+)"
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

                    self.data.append({
                        'frame_position': (frame_x, frame_y),
                        'x1': x1,
                        'y1': y1,
                        'x2': x2,
                        'y2': y2
                    })
                else:
                    print(f"无法解析的行: {line.strip()}")

    def get_data(self):
        """
        返回解析后的数据列表。
        """
        return self.data
