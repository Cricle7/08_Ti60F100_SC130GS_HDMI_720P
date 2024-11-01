from data_loader import CoordinateDataLoader
from trainer import Trainer
from model import FramePredictor  # 假设模型定义在 model.py 中
import numpy as np
import torch
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from torch.utils.data import Dataset

# 定义自定义数据集类
class FrameDataset(Dataset):
    def __init__(self, inputs, labels):
        self.inputs = torch.from_numpy(inputs).float()
        self.labels = torch.from_numpy(labels).float()

    def __len__(self):
        return len(self.inputs)

    def __getitem__(self, idx):
        return self.inputs[idx], self.labels[idx]

if __name__ == "__main__":
    # 加载数据
    file_path = 'coordinates_log.txt'
    data_loader = CoordinateDataLoader(file_path)
    data_loader.load_data()
    data = data_loader.get_data()

    # 准备输入和标签
    inputs = []
    labels = []
    for item in data:
        x1 = item['x1']
        y1 = item['y1']
        x2 = item['x2']
        y2 = item['y2']
        frame_position = item['frame_position']
        inputs.append([x1, y1, x2, y2])
        labels.append(list(frame_position))

    inputs = np.array(inputs, dtype=np.float32)
    labels = np.array(labels, dtype=np.float32)

    # 数据规范化
    input_scaler = StandardScaler()
    inputs = input_scaler.fit_transform(inputs)

    label_scaler = StandardScaler()
    labels = label_scaler.fit_transform(labels)

    # 划分训练集和测试集
    X_train, X_test, y_train, y_test = train_test_split(inputs, labels, test_size=0.2, random_state=42)

    # 创建数据集
    train_dataset = FrameDataset(X_train, y_train)
    test_dataset = FrameDataset(X_test, y_test)

    # 初始化模型
    model = FramePredictor()

    # 初始化训练器
    trainer = Trainer(
        model=model,
        train_dataset=train_dataset,
        test_dataset=test_dataset,
        batch_size=16,
        learning_rate=0.001,
        num_epochs=100
    )

    # 开始训练
    trainer.train()

    # 保存模型
    torch.save(model.state_dict(), 'frame_predictor.pth')
