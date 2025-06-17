# Orinoco Leveling

Este proyecto es parte de la cátedra de Inteligencia Artificial de la Universidad Católica Andrés Bello, realizado por Edwin Rodríguez, Jesús Silva y Sebastian Gomes.

## Estructura del Proyecto

- `backend/`: Modelado, entrenamiento, pruebas y API en Python.
- `frontend/`: Aplicación Flutter para visualización y análisis.

---

## Instrucciones Backend (Python)

### 1. Crear el entorno virtual

Desde la carpeta `backend/` ejecuta:

```powershell
python -m venv ia
```

Activa el entorno virtual:

- En Windows PowerShell:
  ```powershell
  .\ia\Scripts\Activate.ps1
  ```
- En CMD:
  ```cmd
  .\ia\Scripts\activate.bat
  ```

### 2. Instalar dependencias

Con el entorno activado, instala los paquetes necesarios:

```powershell
pip install -r requirements.txt
```

Si no existe `requirements.txt`, instala manualmente:

```powershell
pip install numpy pandas scikit-learn matplotlib tensorflow flask joblib
```

### 3. Generar y entrenar el modelo

Ejecuta el script de tuning y entrenamiento:

```powershell
python lstm_orinoco_tune.py
```

Esto generará el modelo óptimo y los archivos de escalado.

### 4. Probar el modelo

Corre el script de pruebas para ver métricas y gráficas:

```powershell
python test_orinoco_lstm.py
```

### 5. Correr la API

Ejecuta:

```powershell
python orinoco_api.py
```

La API Flask quedará disponible para recibir peticiones.

---

## Instrucciones Frontend (Flutter)

### 1. Instalar Flutter

Sigue la guía oficial: https://docs.flutter.dev/get-started/install

### 2. Instalar dependencias

Desde la carpeta `frontend/` ejecuta:

```powershell
flutter pub get
```

### 3. Correr la aplicación

```powershell
flutter run
```

### 4. Generar build para producción

- Web:
  ```powershell
  flutter build web
  ```
- Windows:
  ```powershell
  flutter build windows
  ```
- Android/iOS:
  ```powershell
  flutter build apk
  flutter build ios
  ```

---

## Créditos

Proyecto de la Universidad Católica Andrés Bello para la cátedra de Inteligencia Artificial.

Realizado por:

- Edwin Rodríguez
- Jesús Silva
- Sebastian Gomes
