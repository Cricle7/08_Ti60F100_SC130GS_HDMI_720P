import numpy as np
from data_loader import CoordinateDataLoader
from sklearn.preprocessing import PolynomialFeatures
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Lasso
from sklearn.model_selection import GridSearchCV
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

# 生成多项式特征（使用2阶）
degree = 2
poly = PolynomialFeatures(degree)
inputs_poly = poly.fit_transform(inputs)  # 不进行标准化，直接使用原始输入

# 忽略前 75 组数据
inputs_poly = inputs_poly[75:]
labels = labels[75:]

# 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(
    inputs_poly, labels, test_size=0.2, random_state=42
)

# 使用 GridSearchCV 进行超参数搜索
param_grid = {
    'alpha': [1e-6, 1e-5, 1e-4, 1e-3, 0.01],
    'max_iter': [50000, 100000, 200000, 500000]
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

# 输出拟合出的多项式
feature_names = poly.get_feature_names_out()
coefficients = best_model.coef_

# 检查是否有多个输出
if coefficients.ndim == 1:
    coefficients = coefficients.reshape(1, -1)  # 将一维数组转换为二维数组以便于后续处理

# 构建多项式表达式
polynomial_expressions = []
for coefs in coefficients:
    polynomial_terms = []
    for coef, name in zip(coefs, feature_names):
        if np.abs(coef) > 1e-5:  # 设置一个阈值以判断是否为零
            polynomial_terms.append(f"{coef:.4f} * {name}")
    polynomial_expression = " + ".join(polynomial_terms)
    polynomial_expressions.append(polynomial_expression)

# 输出多项式表达式
for i, expression in enumerate(polynomial_expressions):
    print(f"拟合出的多项式表达式 for output {i}:")
    print(expression)
