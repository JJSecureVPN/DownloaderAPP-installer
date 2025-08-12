#!/bin/bash

# DownloaderAPP - Script de instalación
# Creado por: @JHServices
# GitHub: https://github.com/JJSecureVPN/DownloaderAPP-installer

clear
echo "🚀 DownloaderAPP - Instalador"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   📱 Subidor de APK con interfaz moderna"
echo "   👤 Creado por: @JHServices"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar sistema operativo
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ Este script está diseñado para sistemas Linux."
    echo "   Para otros sistemas, instala manualmente."
    exit 1
fi

# Verificar si se ejecuta como root
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Verificar e instalar dependencias
echo "📦 Verificando dependencias..."
dependencies=(python3 python3-pip curl)

for dep in "${dependencies[@]}"; do
    if ! command -v ${dep%%-*} >/dev/null 2>&1; then
        echo "   📥 Instalando $dep..."
        $SUDO apt update >/dev/null 2>&1
        $SUDO apt install $dep -y >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "   ✅ $dep instalado correctamente"
        else
            echo "   ❌ Error instalando $dep"
            exit 1
        fi
    else
        echo "   ✅ $dep está disponible"
    fi
done

# Crear directorio de la aplicación
APP_DIR="DownloaderAPP"
echo ""
echo "📁 Configurando aplicación..."

if [ -d "$APP_DIR" ]; then
    echo "   🗑️  Eliminando instalación anterior..."
    rm -rf "$APP_DIR"
fi

mkdir -p $APP_DIR/{app/{routes,static/css,templates},uploads}
cd $APP_DIR

echo "   ✅ Estructura de directorios creada"

# Crear archivo principal (main.py)
echo "📝 Creando archivos del servidor..."
cat > main.py << 'EOF'
import sys

from gevent.pywsgi import WSGIServer
from app import create_app

try:
    port = int(sys.argv[1] if len(sys.argv) > 1 else 5001)
    host = sys.argv[2] if len(sys.argv) > 2 else '0.0.0.0'
    print('[*] Iniciando servidor en {}:{}'.format(host, port))

    http_server = WSGIServer((host, port), create_app())
    http_server.serve_forever()
except KeyboardInterrupt:
    print('[+] Servidor cerrado')
EOF

# Crear app/__init__.py
cat > app/__init__.py << 'EOF'
from flask import Flask

from .routes.index import setup_route


def create_app():
    app = Flask(__name__)

    setup_route(app)

    return app
EOF

# Crear app/routes/__init__.py
touch app/routes/__init__.py

# Crear app/routes/index.py
cat > app/routes/index.py << 'EOF'
import os

from flask import Flask, render_template, request, send_from_directory


upload_folder = os.path.join(os.getcwd(), 'uploads')


def __clean_folder():
    for file in os.listdir(upload_folder):
        print('[*] ELIMINANDO: {}'.format(file))
        os.remove(os.path.join(upload_folder, file))


def index():
    return render_template('index.html')


def upload():
    file = request.files['file']
    if not file:
        return 'Archivo no encontrado', 400

    __clean_folder()
    filename = file.filename.replace(' ', '_')
    print('[*] SUBIENDO: {}'.format(filename))

    file.save(os.path.join(upload_folder, filename))
    url = request.url_root + 'download/' + filename

    print('[*] URL: {}'.format(url))
    return url


def download(filename):
    return send_from_directory(upload_folder, filename)


def setup_route(app: Flask):
    app.add_url_rule('/', 'index', index)
    app.add_url_rule('/upload', 'upload', upload, methods=['POST'])
    app.add_url_rule('/download/<filename>', 'download', download)
EOF

# Crear requirements.txt
cat > requirements.txt << 'EOF'
flask
gevent
EOF

# Crear archivo CSS con diseño moderno
cat > app/static/css/style.css << 'EOF'
@import url('https://fonts.googleapis.com/css?family=Open+Sans:400,700');

* {
    box-sizing: border-box;
}

html,
body {
    margin: 0;
    padding: 0;
}

body {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    width: 100vw;
    font-family: 'Open Sans', sans-serif;
    background: linear-gradient(135deg, #25272c 0%, #1a1c21 100%);
    padding: 20px;
}

.container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 400px;
    width: 100%;
    max-width: 600px;
    background: linear-gradient(145deg, #1e2025 0%, #252831 100%);
    padding: 40px 30px;
    border-radius: 30px;
    box-shadow: 
        0 20px 40px rgba(0, 0, 0, 0.4),
        inset 0 1px 0 rgba(255, 255, 255, 0.1);
    transition: all 0.3s ease;
}

.container:hover {
    transform: translateY(-5px);
    box-shadow: 
        0 30px 60px rgba(0, 0, 0, 0.5),
        inset 0 1px 0 rgba(255, 255, 255, 0.1);
}

.container h1 {
    color: #fff;
    font-size: 2.8rem;
    font-weight: 300;
    margin: 0 0 30px 0;
    text-align: center;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
    letter-spacing: 2px;
}

.form {
    width: 100%;
}

.fileUpload {
    width: 0.1px;
    height: 0.1px;
    opacity: 0;
    overflow: hidden;
    position: absolute;
    z-index: -1;
}

.areaUpload {
    position: relative;
    width: 100%;
    min-height: 120px;
    background: linear-gradient(145deg, #2a2d35 0%, #1f2227 100%);
    border: 3px dashed #4a4d55;
    border-radius: 20px;
    margin-bottom: 25px;
    transition: all 0.3s ease;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
}

.areaUpload:hover {
    border-color: #4CAF50;
    background: linear-gradient(145deg, #2d4a2d 0%, #234323 100%);
    transform: scale(1.02);
}

.areaUpload.dragover {
    border-color: #66BB6A;
    background: linear-gradient(145deg, #2d5a2d 0%, #1e4d1e 100%);
    transform: scale(1.05);
    box-shadow: 0 0 30px rgba(76, 175, 80, 0.3);
}

.uploadText {
    color: #bbb;
    text-align: center;
    font-size: 1rem;
    line-height: 1.4;
    padding: 20px;
    pointer-events: none;
    position: relative;
    z-index: 1;
}

.btnUpload {
    padding: 18px 40px;
    background: linear-gradient(145deg, #4CAF50 0%, #45a049 100%);
    border: none;
    border-radius: 25px;
    width: 100%;
    color: #fff;
    cursor: pointer;
    font-size: 1.1rem;
    font-weight: 600;
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    box-shadow: 0 8px 20px rgba(76, 175, 80, 0.3);
}

.btnUpload:hover:not(:disabled) {
    background: linear-gradient(145deg, #45a049 0%, #3d8b40 100%);
    transform: translateY(-3px);
    box-shadow: 0 12px 25px rgba(76, 175, 80, 0.4);
}

.btnUpload:disabled {
    background: linear-gradient(145deg, #666 0%, #555 100%);
    cursor: not-allowed;
    opacity: 0.6;
    transform: none;
    box-shadow: none;
}

.result {
    width: 100%;
    text-align: center;
    color: #fff;
    animation: fadeIn 0.5s ease-in;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.result h2 {
    color: #4CAF50;
    margin: 0 0 25px 0;
    font-size: 1.8rem;
    font-weight: 400;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.result h2::before {
    content: "✅ ";
    font-size: 1.5rem;
}

.downloadLink {
    margin: 25px 0;
    background: rgba(255, 255, 255, 0.05);
    padding: 20px;
    border-radius: 15px;
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.downloadLink label {
    display: block;
    margin-bottom: 15px;
    color: #ccc;
    font-size: 1rem;
    font-weight: 500;
}

.linkContainer {
    display: flex;
    gap: 12px;
    align-items: stretch;
    flex-direction: column;
}

.linkContainer input[type="text"] {
    width: 100%;
    padding: 15px 20px;
    border: 2px solid #444;
    border-radius: 12px;
    background: linear-gradient(145deg, #2a2d32 0%, #1f2227 100%);
    color: #fff;
    font-size: 0.95rem;
    font-family: 'Courier New', monospace;
    outline: none;
    transition: all 0.3s ease;
    margin-bottom: 10px;
}

.linkContainer input[type="text"]:focus {
    border-color: #2196F3;
    box-shadow: 0 0 15px rgba(33, 150, 243, 0.3);
}

.copyBtn {
    padding: 15px 25px;
    background: linear-gradient(145deg, #2196F3 0%, #1976D2 100%);
    border: none;
    border-radius: 12px;
    color: #fff;
    cursor: pointer;
    font-size: 1rem;
    font-weight: 600;
    transition: all 0.3s ease;
    box-shadow: 0 6px 15px rgba(33, 150, 243, 0.3);
}

.copyBtn:hover {
    background: linear-gradient(145deg, #1976D2 0%, #1565C0 100%);
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(33, 150, 243, 0.4);
}

.newUploadBtn {
    padding: 15px 35px;
    background: linear-gradient(145deg, #FF9800 0%, #F57C00 100%);
    border: none;
    border-radius: 25px;
    color: #fff;
    cursor: pointer;
    font-size: 1.1rem;
    font-weight: 600;
    margin-top: 20px;
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    box-shadow: 0 8px 20px rgba(255, 152, 0, 0.3);
}

.newUploadBtn:hover {
    background: linear-gradient(145deg, #F57C00 0%, #E65100 100%);
    transform: translateY(-3px);
    box-shadow: 0 12px 25px rgba(255, 152, 0, 0.4);
}

.loading {
    text-align: center;
    color: #fff;
    animation: fadeIn 0.5s ease-in;
}

.spinner {
    width: 50px;
    height: 50px;
    margin: 0 auto 25px;
    border: 4px solid rgba(255, 255, 255, 0.1);
    border-top: 4px solid #4CAF50;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.loading p {
    font-size: 1.2rem;
    margin: 0;
    color: #ccc;
    font-weight: 300;
}

@media (max-width: 768px) {
    body {
        padding: 15px;
    }
    
    .container {
        padding: 30px 20px;
        border-radius: 20px;
        min-height: 350px;
    }
    
    .container h1 {
        font-size: 2.2rem;
        margin-bottom: 25px;
    }
    
    .areaUpload {
        min-height: 100px;
    }
    
    .uploadText {
        font-size: 0.9rem;
        padding: 15px;
    }
    
    .linkContainer {
        gap: 10px;
    }
    
    .downloadLink {
        padding: 15px;
    }
}

@media (max-width: 480px) {
    .container h1 {
        font-size: 1.8rem;
        letter-spacing: 1px;
    }
    
    .btnUpload,
    .newUploadBtn {
        font-size: 1rem;
        padding: 15px 25px;
    }
}
EOF

# Crear archivo HTML con interfaz moderna
cat > app/templates/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@JHServices - SUBIR APK</title>
    <link rel="stylesheet" href="../static/css/style.css">
</head>

<body>
    <div class="container">
        <h1>SUBIR APK</h1>
        <form class="form" id="uploadForm" action="/upload" method="POST" enctype="multipart/form-data">
            <label for="file" class="areaUpload">
                <input class="fileUpload" type="file" name="file" id="file" accept=".apk">
                <div class="uploadText">
                    <div style="font-size: 2.5rem; margin-bottom: 10px; opacity: 0.7;">📱</div>
                    Arrastra tu archivo APK aquí o haz clic para seleccionar
                </div>
            </label>
            <input class="btnUpload" type="submit" value="SUBIR" id="uploadBtn" disabled>
        </form>
        
        <div class="result" id="result" style="display: none;">
            <h2>¡Archivo subido exitosamente!</h2>
            <div class="downloadLink">
                <label>Enlace de descarga:</label>
                <div class="linkContainer">
                    <input type="text" id="downloadUrl" readonly>
                    <button onclick="copyToClipboard()" class="copyBtn">📋 Copiar</button>
                </div>
            </div>
            <button onclick="uploadAnother()" class="newUploadBtn">Subir otro archivo</button>
        </div>
        
        <div class="loading" id="loading" style="display: none;">
            <div class="spinner"></div>
            <p>Subiendo archivo...</p>
        </div>
    </div>

    <script>
        const form = document.getElementById('uploadForm');
        const fileInput = document.getElementById('file');
        const uploadBtn = document.getElementById('uploadBtn');
        const result = document.getElementById('result');
        const loading = document.getElementById('loading');
        const downloadUrl = document.getElementById('downloadUrl');
        
        const areaUpload = document.querySelector('.areaUpload');
        
        areaUpload.addEventListener('dragover', (e) => {
            e.preventDefault();
            e.stopPropagation();
            areaUpload.classList.add('dragover');
        });
        
        areaUpload.addEventListener('dragleave', (e) => {
            e.preventDefault();
            e.stopPropagation();
            areaUpload.classList.remove('dragover');
        });
        
        areaUpload.addEventListener('drop', (e) => {
            e.preventDefault();
            e.stopPropagation();
            areaUpload.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0 && files[0].name.toLowerCase().endsWith('.apk')) {
                fileInput.files = files;
                updateFileName();
            } else {
                alert('Por favor selecciona un archivo APK válido');
            }
        });
        
        fileInput.addEventListener('change', updateFileName);
        
        function updateFileName() {
            const file = fileInput.files[0];
            const uploadText = document.querySelector('.uploadText');
            if (file) {
                uploadText.innerHTML = `<div style="font-size: 2.5rem; margin-bottom: 10px; opacity: 0.8;">📱</div>Archivo seleccionado:<br><strong>${file.name}</strong>`;
                uploadBtn.disabled = false;
                uploadBtn.style.opacity = '1';
            } else {
                uploadText.innerHTML = '<div style="font-size: 2.5rem; margin-bottom: 10px; opacity: 0.7;">📱</div>Arrastra tu archivo APK aquí o haz clic para seleccionar';
                uploadBtn.disabled = true;
                uploadBtn.style.opacity = '0.6';
            }
        }
        
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const file = fileInput.files[0];
            if (!file) {
                alert('Por favor selecciona un archivo APK');
                return;
            }
            
            form.style.display = 'none';
            loading.style.display = 'block';
            
            const formData = new FormData();
            formData.append('file', file);
            
            try {
                const response = await fetch('/upload', {
                    method: 'POST',
                    body: formData
                });
                
                if (response.ok) {
                    const url = await response.text();
                    downloadUrl.value = url;
                    
                    loading.style.display = 'none';
                    result.style.display = 'block';
                } else {
                    throw new Error('Error al subir el archivo');
                }
            } catch (error) {
                alert('Error al subir el archivo: ' + error.message);
                loading.style.display = 'none';
                form.style.display = 'block';
            }
        });
        
        function copyToClipboard() {
            downloadUrl.select();
            document.execCommand('copy');
            
            const copyBtn = document.querySelector('.copyBtn');
            const originalText = copyBtn.textContent;
            copyBtn.textContent = '✅ Copiado!';
            setTimeout(() => {
                copyBtn.textContent = originalText;
            }, 2000);
        }
        
        function uploadAnother() {
            result.style.display = 'none';
            form.style.display = 'block';
            form.reset();
            updateFileName();
        }
        
        updateFileName();
    </script>
</body>

</html>
EOF

echo "   ✅ Archivos de la aplicación creados"

# Instalar dependencias de Python
echo ""
echo "🐍 Instalando dependencias de Python..."
pip3 install -r requirements.txt >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "   ✅ Flask y Gevent instalados correctamente"
else
    echo "   ❌ Error instalando dependencias"
    echo "   💡 Intenta instalar manualmente: pip3 install flask gevent"
    exit 1
fi

# Configurar permisos
chmod +x main.py

# Preguntar configuración
echo ""
echo "⚙️  Configuración del servidor:"
read -p "   Puerto (predeterminado: 5001): " -e -i "5001" port

# Validar puerto
if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1024 ] || [ "$port" -gt 65535 ]; then
    echo "   ⚠️  Puerto inválido, usando 5001"
    port=5001
fi

read -p "   ¿Ejecutar en segundo plano? (y/N): " background

echo ""
echo "🚀 Iniciando DownloaderAPP..."

# Obtener dominio configurado
DOMAIN="vps.jhservices.com.ar"

if [[ $background =~ ^[Yy]$ ]]; then
    # Ejecutar en segundo plano
    if command -v screen >/dev/null 2>&1; then
        screen -dmS downloaderapp python3 main.py $port
        echo "   ✅ Servidor iniciado con screen (sesión: downloaderapp)"
        echo "   📋 Para ver logs: screen -r downloaderapp"
        echo "   🛑 Para detener: screen -S downloaderapp -X quit"
    elif command -v nohup >/dev/null 2>&1; then
        nohup python3 main.py $port > server.log 2>&1 &
        echo "   ✅ Servidor iniciado en segundo plano"
        echo "   📋 Para ver logs: tail -f server.log"
        echo "   🛑 Para detener: pkill -f 'python3 main.py'"
    else
        python3 main.py $port &
        echo "   ✅ Servidor iniciado en segundo plano"
    fi
else
    echo "   ▶️  Iniciando servidor en primer plano..."
    echo "   🛑 Presiona Ctrl+C para detener"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 ¡DownloaderAPP instalado correctamente!"
echo ""
echo "🌐 Accede desde:"
echo "   📱 Local:    http://localhost:$port"
echo "   🌍 Público:  http://$DOMAIN:$port"
echo ""
echo "📁 Directorio: $(pwd)"
echo "📋 Creado por: @JHServices"
echo "💬 Telegram: https://t.me/JHServices"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Si no es en segundo plano, ejecutar servidor
if [[ ! $background =~ ^[Yy]$ ]]; then
    echo ""
    python3 main.py $port
fi
