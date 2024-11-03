import numpy as np
from data_loader import CoordinateDataLoader
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import GridSearchCV
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
    sum_value = item['sum']  # 如果需要使用 sum，可以在这里处理

    # 构建输入特征
    inputs.append([
        x1, y1, x2, y2,
        left1, right1, up1, down1,
        left2, right2, up2, down2
    ])

    # 构建标签
    labels.append([frame_x, frame_y])

inputs = np.array(inputs)
labels = np.array(labels)

# 数据预处理
scaler = StandardScaler()
inputs_scaled = scaler.fit_transform(inputs)

# 生成多项式特征（这里使用3阶，可以根据需要调整）
degree = 3
poly = PolynomialFeatures(degree)
inputs_poly = poly.fit_transform(inputs_scaled)

# 忽略前 75 组数据
inputs_poly = inputs_poly[75:]
labels = labels[75:]

# 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(
    inputs_poly, labels, test_size=0.2, random_state=42
)

# 使用 GridSearchCV 进行超参数搜索
param_grid = {
    'alpha': [0.001, 0.01, 0.1, 1],
    'max_iter': [10000, 50000, 100000]
}
lasso = Lasso()
grid_search = GridSearchCV(lasso, param_grid, cv=5, scoring='r2')
grid_search.fit(X_train, y_train)
# 输出最佳参数组合
print("Best parameters:", grid_search.best_params_)
print("Best R² score from cross-validation:", grid_search.best_score_)

# 使用最佳参数重新训练模型
best_model = grid_search.best_estimator_
best_model.fit(X_train, y_train)

# 模型评估
y_pred = best_model.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"均方误差（MSE）: {mse:.4f}")
print(f"R² 得分: {r2:.4f}")
