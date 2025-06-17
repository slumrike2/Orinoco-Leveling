import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
import joblib
import io

# --- PARAMETERS ---
SEQUENCE_LENGTH = 31  # Should match training
MODEL_FILE = 'orinoco_lstm_best_model.keras'
SCALER_FILE = 'orinoco_scaler.save'

# --- LOAD SCALER AND MODEL ---
scaler = joblib.load(SCALER_FILE)
model = load_model(MODEL_FILE)

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'Falta el archivo CSV. Por favor, seleccione un archivo.'}), 400
    file = request.files['file']
    try:
        input_df = pd.read_csv(file)
    except Exception as e:
        return jsonify({'error': f'El archivo CSV no es válido: {str(e)}'}), 400
    # Remove date column if present
    date_col = None
    for col in input_df.columns:
        if 'fecha' in col.lower() or 'date' in col.lower():
            date_col = col
            break
    if date_col:
        dates = pd.to_datetime(input_df[date_col], errors='coerce')
        input_df = input_df.drop(columns=[date_col])
    else:
        dates = None
    if input_df.shape[0] != SEQUENCE_LENGTH:
        return jsonify({'error': f'El archivo debe tener exactamente {SEQUENCE_LENGTH} filas de datos.'}), 400
    if not all(col in input_df.columns for col in ['ayacucho', 'caicara', 'ciudad_bolivar', 'palua']):
        return jsonify({'error': 'El archivo debe contener las columnas: ayacucho, caicara, ciudad_bolivar, palua.'}), 400
    try:
        arr_scaled = scaler.transform(input_df.values)
    except Exception:
        return jsonify({'error': 'Los datos deben ser numéricos y no deben contener valores vacíos.'}), 400
    pred_scaled = model.predict(arr_scaled[np.newaxis, ...])[0]
    pred_scaled = pred_scaled.reshape(7, -1)
    pred = scaler.inverse_transform(pred_scaled)
    pred_list = []
    # Calculate next 7 dates if possible
    next_dates = []
    if dates is not None and not dates.isnull().all():
        last_date = dates.dropna().iloc[-1]
        next_dates = [(last_date + pd.Timedelta(days=i+1)).date().isoformat() for i in range(7)]
    for i, vals in enumerate(pred):
        entry = {col: round(float(val), 2) for col, val in zip(input_df.columns, vals)}
        if next_dates:
            entry['date'] = next_dates[i]
        pred_list.append(entry)
    return jsonify({'7_day_prediction': pred_list})

@app.route('/trend', methods=['POST'])
def trend():
    if 'file' not in request.files:
        return jsonify({'error': 'Missing CSV file'}), 400
    file = request.files['file']
    try:
        input_df = pd.read_csv(file)
    except Exception as e:
        return jsonify({'error': f'Invalid CSV: {str(e)}'}), 400
    if input_df.shape[0] < SEQUENCE_LENGTH:
        return jsonify({'error': f'CSV must have at least {SEQUENCE_LENGTH} rows'}), 400
    trend_results = []
    # For each possible window in the input
    for start_idx in range(0, input_df.shape[0] - SEQUENCE_LENGTH + 1):
        window = input_df.iloc[start_idx:start_idx+SEQUENCE_LENGTH]
        arr_scaled = scaler.transform(window.values)
        pred_scaled = model.predict(arr_scaled[np.newaxis, ...])[0]
        pred_scaled = pred_scaled.reshape(7, -1)
        pred = scaler.inverse_transform(pred_scaled)
        pred_list = []
        for i, vals in enumerate(pred):
            pred_list.append({col: float(val) for col, val in zip(window.columns, vals)})
        trend_results.append({'window_start_row': start_idx, '7_day_prediction': pred_list})
    return jsonify({'trend': trend_results})

if __name__ == '__main__':
    app.run(debug=True)
