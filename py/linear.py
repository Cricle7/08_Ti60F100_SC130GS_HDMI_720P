import numpy as np
from data_loader import CoordinateDataLoader
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import Lasso
from sklearn.metrics import mean_squared_error, r2_score

# 假设 data 已经从数据加载器中获取
file_path = 'coordinates_log.txt'
data_loader = CoordinateDataLoader(file_path)
data_loader.load_data()
data = data_loader.get_data()
inputs = []
labels = []
for item in data:
    x1 = item['x1']
    y1 = item['y1']
    x2 = item['x2']
    y2 = item['y2']
    xb1 = item['xb1']
    yb1 = item['yb1']
    xb2 = item['xb2']
    yb2 = item['yb2']
    frame_position = item['frame_position']
    inputs.append([x1, y1, x2, y2, xb1, yb1, xb2, yb2])
    labels.append(list(frame_position))

inputs = np.array(inputs)
labels = np.array(labels)

# 数据预处理
scaler = StandardScaler()
inputs_scaled = scaler.fit_transform(inputs)

# 生成多项式特征
degree = 1
poly = PolynomialFeatures(degree)
inputs_poly = poly.fit_transform(inputs_scaled)

# 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(
    inputs_poly, labels, test_size=0.2, random_state=42)

# 训练模型
# model = LinearRegression()
model = Lasso(alpha=0.1)  # alpha 是正则化强度
model.fit(X_train, y_train)

# 模型评估
y_pred = model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"均方误差（MSE）: {mse:.4f}")
print(f"R² 得分: {r2:.4f}")

# 预测新数据
# new_input = np.array([[x1_new, y1_new, x2_new, y2_new]])
# new_input_scaled = scaler.transform(new_input)
# new_input_poly = poly.transform(new_input_scaled)
# frame_position_pred = model.predict(new_input_poly)
# print(f"预测的 Frame Position: {frame_position_pred}")
