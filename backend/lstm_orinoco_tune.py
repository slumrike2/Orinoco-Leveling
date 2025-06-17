import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping
import keras_tuner as kt
import joblib

# --- PARAMETERS ---
CSV_FILE = 'orinoco.csv'
SEQUENCE_LENGTH = 31
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

# --- LOAD & CLEAN DATA ---
df = pd.read_csv(CSV_FILE)
df['fecha'] = pd.to_datetime(df['fecha'], errors='coerce')
df = df.dropna(subset=['fecha'])
df = df.sort_values('fecha')
data = df.drop(columns=['fecha'])
data = data.fillna(method='ffill')

# --- NORMALIZE ---
scaler = MinMaxScaler()
data_scaled = scaler.fit_transform(data)

# --- CREATE SEQUENCES ---
def create_sequences(data, seq_length, n_out=7):
    X, y = [], []
    for i in range(len(data) - seq_length - n_out + 1):
        X.append(data[i:i+seq_length])
        y.append(data[i+seq_length:i+seq_length+n_out])
    return np.array(X), np.array(y)

# Use n_out=7 for 7-day output
X, y = create_sequences(data_scaled, SEQUENCE_LENGTH, n_out=7)

# --- SPLIT DATA ---
train_size = int(0.6 * len(X))
val_size = int(0.2 * len(X))
# Update y_train/y_val shape for training
X_train = X[:train_size]
y_train = y[:train_size].reshape(-1, 7 * data.shape[1])
X_val = X[train_size:train_size+val_size]
y_val = y[train_size:train_size+val_size].reshape(-1, 7 * data.shape[1])

# --- HYPERPARAMETER TUNING ---
def build_model(hp):
    model = Sequential()
    model.add(LSTM(
        hp.Int('lstm1_units', min_value=16, max_value=128, step=16),
        input_shape=(SEQUENCE_LENGTH, data.shape[1]),
        return_sequences=True
    ))
    model.add(Dropout(hp.Float('dropout1', 0.1, 0.5, step=0.1)))
    model.add(LSTM(
        hp.Int('lstm2_units', min_value=8, max_value=64, step=8),
        return_sequences=False
    ))
    model.add(Dropout(hp.Float('dropout2', 0.1, 0.5, step=0.1)))
    model.add(Dense(7 * data.shape[1]))  # Output 7 days for all rivers
    model.compile(
        optimizer='adam',
        loss='mse',
        metrics=['mae']
    )
    return model

tuner = kt.RandomSearch(
    build_model,
    objective='val_mae',
    max_trials=10,
    executions_per_trial=1,
    directory='orinoco_tuning',
    project_name='orinoco_lstm'
)

tuner.search(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=50,
    batch_size=32,
    callbacks=[EarlyStopping(patience=5, restore_best_weights=True)],
    verbose=1
)

best_hp = tuner.get_best_hyperparameters(1)[0]
print('Best hyperparameters:')
print(f"LSTM1 units: {best_hp.get('lstm1_units')}")
print(f"Dropout1: {best_hp.get('dropout1')}")
print(f"LSTM2 units: {best_hp.get('lstm2_units')}")
print(f"Dropout2: {best_hp.get('dropout2')}")

# --- TRAIN FINAL MODEL WITH BEST HP ---
best_model = tuner.hypermodel.build(best_hp)
history = best_model.fit(
    X_train, y_train,
    validation_data=(X_val, y_val),
    epochs=100,
    batch_size=32,
    callbacks=[EarlyStopping(patience=10, restore_best_weights=True)],
    verbose=1
)

# --- EXPORT MODEL AND SCALER ---
best_model.save('orinoco_lstm_best_model.keras')
joblib.dump(scaler, 'orinoco_scaler.save')
print('Best model and scaler exported.')
