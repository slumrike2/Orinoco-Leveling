import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping
import matplotlib.pyplot as plt
import joblib

# --- PARAMETERS ---
CSV_FILE = 'orinoco.csv'
SEQUENCE_LENGTH = 31  # Use 3 days to predict next day
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

# --- LOAD & CLEAN DATA ---
df = pd.read_csv(CSV_FILE)
df['fecha'] = pd.to_datetime(df['fecha'], errors='coerce')
df = df.dropna(subset=['fecha'])
df = df.sort_values('fecha')

# Remove any non-numeric columns except date
data = df.drop(columns=['fecha'])
# Fill missing values with previous value (forward fill)
data = data.fillna(method='ffill')

# --- NORMALIZE ---
scaler = MinMaxScaler()
data_scaled = scaler.fit_transform(data)

# --- CREATE SEQUENCES ---
def create_sequences(data, seq_length):
    X, y = [], []
    for i in range(len(data) - seq_length):
        X.append(data[i:i+seq_length])
        y.append(data[i+seq_length])
    return np.array(X), np.array(y)

X, y = create_sequences(data_scaled, SEQUENCE_LENGTH)

# --- SPLIT DATA INTO TRAIN, VALIDATION, AND TEST SETS ---
# Recommended: 60% train, 20% validation, 20% test (no shuffling for time series)
train_size = int(0.6 * len(X))
val_size = int(0.2 * len(X))
test_size = len(X) - train_size - val_size

X_train = X[:train_size]
y_train = y[:train_size]
X_val = X[train_size:train_size+val_size]
y_val = y[train_size:train_size+val_size]
X_test = X[train_size+val_size:]
y_test = y[train_size+val_size:]

# --- BUILD LSTM MODEL (Best Practices) ---
model = Sequential([
    LSTM(64, input_shape=(SEQUENCE_LENGTH, data.shape[1]), return_sequences=True),
    Dropout(0.2),
    LSTM(32, return_sequences=False),
    Dropout(0.2),
    Dense(data.shape[1])  # Multi-output: one for each river
])
model.compile(optimizer='adam', loss='mse', metrics=['mae'])  # Add MAE as a metric

# --- TRAIN ---
es = EarlyStopping(patience=15, restore_best_weights=True)
history = model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=200,
    batch_size=32,
    callbacks=[es],
    verbose=1
)

# --- EVALUATE ---
loss, mae = model.evaluate(X_test, y_test, verbose=0)
print(f'Test MSE loss: {loss:.4f}')
print(f'Test MAE (precision): {mae:.4f}')

# --- PREDICT (example: last 3 days) ---
last_seq = data_scaled[-SEQUENCE_LENGTH:]
pred_scaled = model.predict(last_seq[np.newaxis, ...])[0]
pred = scaler.inverse_transform([pred_scaled])[0]
print('\nPredicted next day water levels:')
for i, col in enumerate(data.columns):
    print(f'{col}: {pred[i]:.2f}')

# --- Plot training history ---
plt.figure()
plt.plot(history.history['loss'], label='train_loss')
plt.plot(history.history['val_loss'], label='val_loss')
plt.plot(history.history['mae'], label='train_mae')
plt.plot(history.history['val_mae'], label='val_mae')
plt.legend()
plt.title('Training Loss and MAE (Precision)')
plt.savefig('training_history.png')
plt.close()

# --- Predict for test set and plot ---
y_pred_scaled = model.predict(X_test)
y_pred = scaler.inverse_transform(y_pred_scaled)
y_true = scaler.inverse_transform(y_test)
plt.figure(figsize=(10,5))
plt.plot(y_true[:,0], label='True Ayacucho')
plt.plot(y_pred[:,0], label='Pred Ayacucho')
plt.legend()
plt.title('Ayacucho River Level Prediction')
plt.savefig('ayacucho_prediction.png')
plt.close()

# --- EXPORT MODEL AND SCALER ---
model.save('orinoco_lstm_model.keras')
joblib.dump(scaler, 'orinoco_scaler.save')

print('Model and scaler exported.')
