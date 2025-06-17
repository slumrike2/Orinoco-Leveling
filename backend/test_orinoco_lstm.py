import numpy as np
import pandas as pd
from tensorflow.keras.models import load_model
import joblib
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

# --- PARAMETERS ---
CSV_FILE = 'orinoco.csv'
SEQUENCE_LENGTH = 31  # Should match training
MODEL_FILE = 'orinoco_lstm_best_model.keras'
SCALER_FILE = 'orinoco_scaler.save'

# --- LOAD DATA ---
df = pd.read_csv(CSV_FILE)
df['fecha'] = pd.to_datetime(df['fecha'], errors='coerce')
df = df.dropna(subset=['fecha'])
df = df.sort_values('fecha')
data = df.drop(columns=['fecha'])
data = data.fillna(method='ffill')

# --- LOAD SCALER AND MODEL ---
scaler = joblib.load(SCALER_FILE)
model = load_model(MODEL_FILE)

# --- NORMALIZE ---
data_scaled = scaler.transform(data)

# --- PREDICT NEXT 7 DAYS FOR EACH RIVER ---
last_seq = data_scaled[-SEQUENCE_LENGTH:]
pred_scaled = model.predict(last_seq[np.newaxis, ...])[0]
pred_scaled = pred_scaled.reshape(7, -1)  # 7 days, n_features
pred = scaler.inverse_transform(pred_scaled)

print('Predicted next 7 days water levels:')
for day, vals in enumerate(pred):
    print(f'Day {day+1}:')
    for i, col in enumerate(data.columns):
        print(f'  {col}: {vals[i]:.2f}')

# --- PREDICT FOR TEST SET ---
# Use the last 20% of the data as test set (same as in training script)
test_size = int(0.2 * len(data_scaled))
X_test = []
y_test = []
for i in range(len(data_scaled) - test_size - 7 + 1):
    X_test.append(data_scaled[i:i+SEQUENCE_LENGTH])
    y_test.append(data_scaled[i+SEQUENCE_LENGTH:i+SEQUENCE_LENGTH+7])
X_test = np.array(X_test)
y_test = np.array(y_test).reshape(-1, 7 * data.shape[1])

# Predict
y_pred_scaled = model.predict(X_test)
y_pred = scaler.inverse_transform(y_pred_scaled.reshape(-1, data.shape[1])).reshape(-1, 7 * data.shape[1])
y_true = scaler.inverse_transform(y_test.reshape(-1, data.shape[1])).reshape(-1, 7 * data.shape[1])

# --- METRICS ---
metrics = {}
all_true = []
all_pred = []
for i, col in enumerate(data.columns):
    mse = mean_squared_error(y_true[:, i::data.shape[1]], y_pred[:, i::data.shape[1]])
    mae = mean_absolute_error(y_true[:, i::data.shape[1]], y_pred[:, i::data.shape[1]])
    r2 = r2_score(y_true[:, i::data.shape[1]], y_pred[:, i::data.shape[1]])
    true_vals = y_true[:, i::data.shape[1]].flatten()
    pred_vals = y_pred[:, i::data.shape[1]].flatten()
    all_true.append(true_vals)
    all_pred.append(pred_vals)
    tolerance = 0.05 * np.abs(true_vals)  # 5% tolerance
    within_tolerance = np.abs(pred_vals - true_vals) <= tolerance
    precision_pct = 100 * np.sum(within_tolerance) / len(true_vals)
    metrics[col] = {'MSE': mse, 'MAE': mae, 'R2': r2, 'Precision (%)': precision_pct}
    print(f'\nMetrics for {col}:')
    print(f'MSE: {mse:.4f}')
    print(f'MAE: {mae:.4f}')
    print(f'R2: {r2:.4f}')
    print(f'Precision (within 5%): {precision_pct:.2f}%')

    # Plot true vs predicted
    plt.figure(figsize=(10, 5))
    plt.plot(y_true[:, i], label='True')
    plt.plot(y_pred[:, i], label='Predicted')
    plt.title(f'{col} - True vs Predicted')
    plt.xlabel('Time step')
    plt.ylabel('Water Level')
    plt.legend()
    plt.tight_layout()
    plt.savefig(f'{col}_true_vs_pred.png')
    plt.close()

# Calculate overall precision across all data (5% tolerance)
all_true_flat = np.concatenate(all_true)
all_pred_flat = np.concatenate(all_pred)
overall_tolerance = 0.05 * np.abs(all_true_flat)
overall_within_tolerance = np.abs(all_pred_flat - all_true_flat) <= overall_tolerance
overall_precision_pct = 100 * np.sum(overall_within_tolerance) / len(all_true_flat)
print(f'\nOverall Precision (within 5% for all data): {overall_precision_pct:.2f}%')

# --- PLOT METRICS FOR ALL RIVERS ---
# Bar plots for MSE, MAE, R2, Precision (%)
for metric in ['MSE', 'MAE', 'R2', 'Precision (%)']:
    plt.figure()
    plt.bar(metrics.keys(), [metrics[col][metric] for col in metrics])
    plt.title(f'{metric} for all rivers')
    plt.ylabel(metric)
    plt.tight_layout()
    plt.savefig(f'all_rivers_{metric.replace(" (%)", "_pct")}.png')
    plt.close()
