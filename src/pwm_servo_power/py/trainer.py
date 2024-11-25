import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from tqdm import tqdm  # 用于显示进度条

class Trainer:
    def __init__(self, model, train_dataset, test_dataset=None, batch_size=32, learning_rate=0.001, num_epochs=100):
        self.model = model
        self.train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
        self.test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False) if test_dataset else None
        self.criterion = nn.MSELoss()
        self.optimizer = torch.optim.Adam(self.model.parameters(), lr=learning_rate)
        self.num_epochs = num_epochs

    def train(self):
        for epoch in range(self.num_epochs):
            self.model.train()
            epoch_loss = 0.0
            progress_bar = tqdm(self.train_loader, desc=f'Epoch {epoch+1}/{self.num_epochs}')
            for batch_inputs, batch_labels in progress_bar:
                outputs = self.model(batch_inputs)
                loss = self.criterion(outputs, batch_labels)
                self.optimizer.zero_grad()
                loss.backward()
                self.optimizer.step()
                epoch_loss += loss.item()
                progress_bar.set_postfix(loss=loss.item())
            avg_epoch_loss = epoch_loss / len(self.train_loader)
            print(f'Epoch [{epoch+1}/{self.num_epochs}], Training Loss: {avg_epoch_loss:.4f}')

            # 如果有验证集，可以在这里进行评估
            if self.test_loader:
                self.evaluate()

    def evaluate(self):
        self.model.eval()
        total_loss = 0.0
        with torch.no_grad():
            for batch_inputs, batch_labels in self.test_loader:
                outputs = self.model(batch_inputs)
                loss = self.criterion(outputs, batch_labels)
                total_loss += loss.item()
        avg_loss = total_loss / len(self.test_loader)
        print(f'Validation Loss: {avg_loss:.4f}')
