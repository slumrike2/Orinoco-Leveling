import pandas as pd
import numpy as np
from tensorflow.keras.models import load_model
import joblib
import tkinter as tk
from tkinter import messagebox
from datetime import datetime, timedelta

# --- PARAMETERS ---
CSV_FILE = 'orinoco.csv'
SEQUENCE_LENGTH = 31
MODEL_FILE = 'orinoco_lstm_best_model.keras'
SCALER_FILE = 'orinoco_scaler.save'

# --- LOAD DATA, SCALER, AND MODEL ---
df = pd.read_csv(CSV_FILE)
df['fecha'] = pd.to_datetime(df['fecha'], errors='coerce')
df = df.dropna(subset=['fecha'])
df = df.sort_values('fecha')
data = df.drop(columns=['fecha'])
data = data.fillna(method='ffill')
scaler = joblib.load(SCALER_FILE)
model = load_model(MODEL_FILE)

# --- PREDICTION FUNCTION ---
def predict_for_date(date_str):
    try:
        date = pd.to_datetime(date_str)
    except Exception:
        return None, 'Invalid date format. Use YYYY-MM-DD.'
    # Find the index of the date
    idx = df.index[df['fecha'] == date]
    if len(idx) == 0:
        return None, 'Date not found in data.'
    idx = idx[0]
    # Check if enough previous data exists
    if idx < SEQUENCE_LENGTH:
        return None, f'Not enough previous data for {SEQUENCE_LENGTH} days.'
    seq = data.iloc[idx-SEQUENCE_LENGTH:idx].values
    seq_scaled = scaler.transform(seq)
    pred_scaled = model.predict(seq_scaled[np.newaxis, ...])[0]
    pred = scaler.inverse_transform([pred_scaled])[0]
    return pred, None

# --- TKINTER INTERFACE ---
def on_predict():
    date_str = entry.get()
    pred, err = predict_for_date(date_str)
    if err:
        messagebox.showerror('Error', err)
    else:
        result = '\n'.join([f'{col}: {pred[i]:.2f}' for i, col in enumerate(data.columns)])
        messagebox.showinfo('Prediction', f'Prediction for {date_str}:\n{result}')

root = tk.Tk()
root.title('Orinoco LSTM Predictor')
root.geometry('350x200')

label = tk.Label(root, text='Enter date (YYYY-MM-DD):')
label.pack(pady=10)
entry = tk.Entry(root, width=20)
entry.pack(pady=5)
predict_btn = tk.Button(root, text='Predict', command=on_predict)
predict_btn.pack(pady=10)

root.mainloop()
