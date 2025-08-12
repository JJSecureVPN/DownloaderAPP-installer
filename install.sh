#!/bin/bash

# Instalador público para DownloaderAPP
# Versión: 2.0 - Sistema de gestión de archivos persistente
# Dominio: vps.jhservices.com.ar

echo "🚀 DownloaderAPP v2.0 - Instalador Automático"
echo "================================================"
echo "✨ Sistema de gestión de archivos persistente"
echo "📱 Subidor de APK con interfaz moderna"
echo "🔧 Desarrollado por @JHServices"
echo ""

# Variables de configuración
DOMAIN="vps.jhservices.com.ar"
PROJECT_NAME="DownloaderAPP"
UPLOAD_DIR="uploads"

# Verificar permisos de root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Este script debe ejecutarse como root"
   echo "💡 Ejecuta: sudo bash <(curl -s https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh)"
   exit 1
fi

# Función para instalar dependencias
install_dependencies() {
    echo "📦 Instalando dependencias..."
    dependencies=(git python3 python3-pip screen curl)
    
    # Actualizar repositorios
    apt update -qq &>/dev/null
    
    for dependence in "${dependencies[@]}"; do
        if ! command -v $dependence >/dev/null 2>&1; then
            echo "   ├── Instalando $dependence..."
            apt install $dependence -y -qq &>/dev/null
            if [ $? -eq 0 ]; then
                echo "   ├── ✅ $dependence instalado correctamente"
            else
                echo "   ├── ❌ Error instalando $dependence"
                exit 1
            fi
        else
            echo "   ├── ✅ $dependence ya está instalado"
        fi
    done
    echo "   └── 🎉 Todas las dependencias instaladas"
}

# Función para crear la aplicación
create_app() {
    echo ""
    echo "📁 Creando estructura del proyecto..."
    
    # Crear directorio principal
    mkdir -p $PROJECT_NAME
    cd $PROJECT_NAME
    
    # Crear estructura de directorios
    mkdir -p app/routes app/static/css app/templates $UPLOAD_DIR
    
    echo "   ├── 📂 Estructura de directorios creada"
    
    # Crear requirements.txt
    cat > requirements.txt << 'EOF'
Flask==2.3.3
gevent==23.7.0
EOF
    
    # Crear main.py
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
import os
from flask import Flask

def create_app():
    app = Flask(__name__)
    
    upload_folder = os.path.join(os.getcwd(), 'uploads')
    
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)
    
    from app.routes.index import setup_route
    setup_route(app)
    
    return app
EOF
    
    # Crear app/routes/__init__.py
    touch app/routes/__init__.py
    
    # Crear app/routes/index.py
    cat > app/routes/index.py << 'EOF'
import os
import json
from datetime import datetime

from flask import Flask, render_template, request, send_from_directory, jsonify


upload_folder = os.path.join(os.getcwd(), 'uploads')


def __clean_folder():
    """Función para limpiar toda la carpeta (solo usar cuando sea necesario)"""
    for file in os.listdir(upload_folder):
        print('[*] ELIMINANDO: {}'.format(file))
        os.remove(os.path.join(upload_folder, file))


def __get_file_info():
    """Obtiene información de todos los archivos APK en uploads"""
    files_info = []
    if os.path.exists(upload_folder):
        for filename in os.listdir(upload_folder):
            if filename.lower().endswith('.apk'):
                file_path = os.path.join(upload_folder, filename)
                stat = os.stat(file_path)
                files_info.append({
                    'filename': filename,
                    'size': stat.st_size,
                    'modified': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S'),
                    'download_url': request.url_root + 'download/' + filename
                })
    return files_info


def __file_exists(filename):
    """Verifica si un archivo ya existe"""
    return os.path.exists(os.path.join(upload_folder, filename))


def index():
    return render_template('index.html')


def get_files():
    """Endpoint para obtener la lista de archivos existentes"""
    return jsonify(__get_file_info())


def upload():
    file = request.files['file']
    if not file:
        return 'Archivo no encontrado', 400

    if not file.filename.lower().endswith('.apk'):
        return 'Solo se permiten archivos APK', 400

    filename = file.filename.replace(' ', '_')
    file_path = os.path.join(upload_folder, filename)
    
    # Verificar si el archivo ya existe
    if __file_exists(filename):
        action = request.form.get('action', 'replace')  # Por defecto reemplazar
        
        if action == 'keep_both':
            # Generar nombre único agregando timestamp
            name, ext = os.path.splitext(filename)
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"{name}_{timestamp}{ext}"
            file_path = os.path.join(upload_folder, filename)
        elif action == 'cancel':
            return jsonify({
                'error': 'Upload cancelled',
                'existing_file': filename
            }), 409
        # Si action == 'replace', simplemente sobrescribimos el archivo
    
    print('[*] SUBIENDO: {}'.format(filename))
    file.save(file_path)
    
    url = request.url_root + 'download/' + filename
    print('[*] URL: {}'.format(url))
    
    return jsonify({
        'success': True,
        'filename': filename,
        'download_url': url,
        'files': __get_file_info()
    })


def delete_file(filename):
    """Endpoint para eliminar un archivo específico"""
    file_path = os.path.join(upload_folder, filename)
    if os.path.exists(file_path):
        os.remove(file_path)
        print('[*] ELIMINADO: {}'.format(filename))
        return jsonify({'success': True, 'message': f'Archivo {filename} eliminado'})
    else:
        return jsonify({'error': 'Archivo no encontrado'}), 404


def clear_all():
    """Endpoint para limpiar todos los archivos"""
    __clean_folder()
    return jsonify({'success': True, 'message': 'Todos los archivos eliminados'})


def download(filename):
    return send_from_directory(upload_folder, filename)


def setup_route(app: Flask):
    app.add_url_rule('/', 'index', index)
    app.add_url_rule('/upload', 'upload', upload, methods=['POST'])
    app.add_url_rule('/files', 'get_files', get_files, methods=['GET'])
    app.add_url_rule('/delete/<filename>', 'delete_file', delete_file, methods=['DELETE'])
    app.add_url_rule('/clear', 'clear_all', clear_all, methods=['POST'])
    app.add_url_rule('/download/<filename>', 'download', download)
EOF
    
    echo "   ├── 🐍 Código Python creado"
    
    # Crear HTML template
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
        
        <!-- Sección de archivos existentes -->
        <div class="files-section" id="filesSection" style="display: none;">
            <h3>📱 Archivos APK disponibles:</h3>
            <div class="files-list" id="filesList"></div>
            <button onclick="clearAllFiles()" class="clearBtn">🗑️ Limpiar todo</button>
        </div>
        
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
        
        <!-- Modal para archivos duplicados -->
        <div class="modal" id="duplicateModal" style="display: none;">
            <div class="modal-content">
                <h3>⚠️ Archivo ya existe</h3>
                <p>El archivo <strong id="duplicateFileName"></strong> ya existe. ¿Qué deseas hacer?</p>
                <div class="modal-buttons">
                    <button onclick="handleDuplicate('replace')" class="modal-btn replace-btn">🔄 Reemplazar</button>
                    <button onclick="handleDuplicate('keep_both')" class="modal-btn keep-btn">📁 Mantener ambos</button>
                    <button onclick="handleDuplicate('cancel')" class="modal-btn cancel-btn">❌ Cancelar</button>
                </div>
            </div>
        </div>
        
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
        const filesSection = document.getElementById('filesSection');
        const filesList = document.getElementById('filesList');
        const duplicateModal = document.getElementById('duplicateModal');
        
        let currentFile = null;
        let duplicateAction = null;
        
        const areaUpload = document.querySelector('.areaUpload');
        
        // Cargar archivos existentes al iniciar
        loadExistingFiles();
        
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
        
        async function loadExistingFiles() {
            try {
                const response = await fetch('/files');
                const files = await response.json();
                
                if (files.length > 0) {
                    displayFiles(files);
                    filesSection.style.display = 'block';
                } else {
                    filesSection.style.display = 'none';
                }
            } catch (error) {
                console.error('Error cargando archivos:', error);
            }
        }
        
        function displayFiles(files) {
            filesList.innerHTML = '';
            files.forEach(file => {
                const fileItem = document.createElement('div');
                fileItem.className = 'file-item';
                
                const size = formatFileSize(file.size);
                
                fileItem.innerHTML = `
                    <div class="file-info">
                        <strong>📱 ${file.filename}</strong>
                        <div class="file-details">
                            <span>📊 ${size}</span>
                            <span>🕒 ${file.modified}</span>
                        </div>
                    </div>
                    <div class="file-actions">
                        <button onclick="copyFileUrl('${file.download_url}')" class="file-btn copy-btn">📋</button>
                        <a href="${file.download_url}" download class="file-btn download-btn">⬇️</a>
                        <button onclick="deleteFile('${file.filename}')" class="file-btn delete-btn">🗑️</button>
                    </div>
                `;
                
                filesList.appendChild(fileItem);
            });
        }
        
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 B';
            const k = 1024;
            const sizes = ['B', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }
        
        async function deleteFile(filename) {
            if (confirm(`¿Estás seguro de que quieres eliminar ${filename}?`)) {
                try {
                    const response = await fetch(`/delete/${filename}`, {
                        method: 'DELETE'
                    });
                    
                    if (response.ok) {
                        await loadExistingFiles();
                        alert('Archivo eliminado correctamente');
                    } else {
                        alert('Error al eliminar el archivo');
                    }
                } catch (error) {
                    alert('Error al eliminar el archivo');
                }
            }
        }
        
        async function clearAllFiles() {
            if (confirm('¿Estás seguro de que quieres eliminar TODOS los archivos? Esta acción no se puede deshacer.')) {
                try {
                    const response = await fetch('/clear', {
                        method: 'POST'
                    });
                    
                    if (response.ok) {
                        await loadExistingFiles();
                        alert('Todos los archivos eliminados correctamente');
                    } else {
                        alert('Error al eliminar los archivos');
                    }
                } catch (error) {
                    alert('Error al eliminar los archivos');
                }
            }
        }
        
        function copyFileUrl(url) {
            navigator.clipboard.writeText(url).then(() => {
                alert('¡Enlace copiado al portapapeles!');
            });
        }
        
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const file = fileInput.files[0];
            if (!file) {
                alert('Por favor selecciona un archivo APK');
                return;
            }
            
            currentFile = file;
            
            // Verificar si el archivo ya existe
            const response = await fetch('/files');
            const existingFiles = await response.json();
            const fileExists = existingFiles.some(f => f.filename === file.name.replace(' ', '_'));
            
            if (fileExists) {
                document.getElementById('duplicateFileName').textContent = file.name;
                duplicateModal.style.display = 'flex';
                return;
            }
            
            // Si no existe, subir directamente
            uploadFile('replace');
        });
        
        function handleDuplicate(action) {
            duplicateModal.style.display = 'none';
            if (action === 'cancel') {
                return;
            }
            uploadFile(action);
        }
        
        async function uploadFile(action) {
            form.style.display = 'none';
            loading.style.display = 'block';
            
            const formData = new FormData();
            formData.append('file', currentFile);
            formData.append('action', action);
            
            try {
                const response = await fetch('/upload', {
                    method: 'POST',
                    body: formData
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    downloadUrl.value = data.download_url;
                    
                    loading.style.display = 'none';
                    result.style.display = 'block';
                    
                    // Actualizar lista de archivos
                    await loadExistingFiles();
                } else {
                    throw new Error(data.error || 'Error al subir el archivo');
                }
            } catch (error) {
                alert('Error al subir el archivo: ' + error.message);
                loading.style.display = 'none';
                form.style.display = 'block';
            }
        }
        
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
    
    echo "   ├── 🌐 Template HTML creado"
    
    # Crear CSS
    cat > app/static/css/style.css << 'EOF'
@import url('https://fonts.googleapis.com/css?family=Open+Sans:400,700');

* {
    box-sizing: border-box;
}

html,
body {
    margin: 0;
    padding: 0;
    min-height: 100vh;
}

body {
    font-family: 'Open Sans', sans-serif;
    background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
    color: #fff;
    padding: 20px;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}

.container {
    background: rgba(255, 255, 255, 0.05);
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 20px;
    padding: 30px;
    max-width: 600px;
    width: 100%;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    text-align: center;
}

.container h1 {
    color: #fff;
    font-size: 2.5rem;
    font-weight: 700;
    margin-bottom: 30px;
    text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

/* Sección de archivos existentes */
.files-section {
    margin-bottom: 30px;
    text-align: left;
}

.files-section h3 {
    color: #fff;
    margin-bottom: 15px;
    font-size: 1.2rem;
}

.files-list {
    background: rgba(255, 255, 255, 0.05);
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
    max-height: 300px;
    overflow-y: auto;
}

.file-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    margin-bottom: 10px;
    transition: all 0.3s ease;
}

.file-item:hover {
    background: rgba(255, 255, 255, 0.15);
    transform: translateY(-2px);
}

.file-item:last-child {
    margin-bottom: 0;
}

.file-info {
    flex: 1;
}

.file-info strong {
    display: block;
    margin-bottom: 5px;
    color: #fff;
}

.file-details {
    font-size: 0.9rem;
    opacity: 0.7;
}

.file-details span {
    margin-right: 15px;
}

.file-actions {
    display: flex;
    gap: 5px;
}

.file-btn {
    background: rgba(255, 255, 255, 0.2);
    border: none;
    border-radius: 5px;
    padding: 8px 10px;
    color: #fff;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
}

.file-btn:hover {
    background: rgba(255, 255, 255, 0.3);
    transform: scale(1.1);
}

.copy-btn:hover {
    background: rgba(52, 152, 219, 0.7);
}

.download-btn:hover {
    background: rgba(46, 204, 113, 0.7);
}

.delete-btn:hover {
    background: rgba(231, 76, 60, 0.7);
}

.clearBtn {
    background: linear-gradient(135deg, #e74c3c, #c0392b);
    border: none;
    border-radius: 10px;
    padding: 10px 20px;
    color: #fff;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s ease;
    width: 100%;
}

.clearBtn:hover {
    background: linear-gradient(135deg, #c0392b, #a93226);
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(231, 76, 60, 0.4);
}

/* Formulario de subida */
.form {
    width: 100%;
    margin-bottom: 20px;
}

.areaUpload {
    position: relative;
    width: 100%;
    min-height: 150px;
    background: rgba(255, 255, 255, 0.05);
    border: 2px dashed rgba(255, 255, 255, 0.3);
    border-radius: 15px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
    overflow: hidden;
}

.areaUpload:hover {
    border-color: rgba(255, 255, 255, 0.6);
    background: rgba(255, 255, 255, 0.1);
}

.areaUpload.dragover {
    border-color: #3498db;
    background: rgba(52, 152, 219, 0.2);
    transform: scale(1.02);
}

.fileUpload {
    position: absolute;
    width: 100%;
    height: 100%;
    opacity: 0;
    cursor: pointer;
}

.uploadText {
    text-align: center;
    color: #fff;
    font-size: 1.1rem;
    padding: 20px;
    pointer-events: none;
    transition: all 0.3s ease;
}

.btnUpload {
    width: 100%;
    padding: 15px;
    background: linear-gradient(135deg, #3498db, #2980b9);
    border: none;
    border-radius: 10px;
    color: #fff;
    font-size: 1.1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    opacity: 0.6;
}

.btnUpload:enabled {
    opacity: 1;
}

.btnUpload:enabled:hover {
    background: linear-gradient(135deg, #2980b9, #21618c);
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
}

.btnUpload:disabled {
    cursor: not-allowed;
}

/* Modal para duplicados */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
}

.modal-content {
    background: linear-gradient(135deg, #2c3e50, #34495e);
    border-radius: 15px;
    padding: 30px;
    max-width: 400px;
    width: 90%;
    text-align: center;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

.modal-content h3 {
    margin-top: 0;
    color: #f39c12;
    font-size: 1.5rem;
}

.modal-content p {
    margin: 20px 0;
    color: #ecf0f1;
    font-size: 1.1rem;
}

.modal-buttons {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    justify-content: center;
}

.modal-btn {
    flex: 1;
    min-width: 110px;
    padding: 12px 20px;
    border: none;
    border-radius: 8px;
    color: #fff;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    font-size: 0.95rem;
}

.replace-btn {
    background: linear-gradient(135deg, #f39c12, #e67e22);
}

.replace-btn:hover {
    background: linear-gradient(135deg, #e67e22, #d35400);
}

.keep-btn {
    background: linear-gradient(135deg, #27ae60, #229954);
}

.keep-btn:hover {
    background: linear-gradient(135deg, #229954, #1e8449);
}

.cancel-btn {
    background: linear-gradient(135deg, #95a5a6, #7f8c8d);
}

.cancel-btn:hover {
    background: linear-gradient(135deg, #7f8c8d, #6c7b7d);
}

/* Resultados */
.result {
    background: rgba(46, 204, 113, 0.1);
    border: 1px solid rgba(46, 204, 113, 0.3);
    border-radius: 15px;
    padding: 30px;
    text-align: center;
}

.result h2 {
    color: #2ecc71;
    margin-top: 0;
    font-size: 1.8rem;
}

.downloadLink {
    margin: 20px 0;
}

.downloadLink label {
    display: block;
    margin-bottom: 10px;
    font-weight: 600;
    color: #fff;
}

.linkContainer {
    display: flex;
    gap: 10px;
    align-items: center;
}

.linkContainer input {
    flex: 1;
    padding: 12px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.1);
    color: #fff;
    font-size: 0.95rem;
}

.linkContainer input:focus {
    outline: none;
    border-color: #3498db;
    background: rgba(255, 255, 255, 0.15);
}

.copyBtn {
    background: linear-gradient(135deg, #3498db, #2980b9);
    border: none;
    border-radius: 8px;
    padding: 12px 20px;
    color: #fff;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s ease;
    white-space: nowrap;
}

.copyBtn:hover {
    background: linear-gradient(135deg, #2980b9, #21618c);
}

.newUploadBtn {
    background: linear-gradient(135deg, #9b59b6, #8e44ad);
    border: none;
    border-radius: 10px;
    padding: 12px 30px;
    color: #fff;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s ease;
    margin-top: 20px;
}

.newUploadBtn:hover {
    background: linear-gradient(135deg, #8e44ad, #7d3c98);
    transform: translateY(-2px);
}

/* Loading */
.loading {
    text-align: center;
    padding: 40px;
}

.spinner {
    width: 50px;
    height: 50px;
    border: 4px solid rgba(255, 255, 255, 0.3);
    border-top: 4px solid #3498db;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto 20px;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.loading p {
    color: #fff;
    font-size: 1.2rem;
    margin: 0;
}

/* Responsive */
@media (max-width: 600px) {
    .container {
        margin: 10px;
        padding: 20px;
    }
    
    .container h1 {
        font-size: 2rem;
    }
    
    .file-item {
        flex-direction: column;
        text-align: center;
        gap: 10px;
    }
    
    .file-actions {
        justify-content: center;
    }
    
    .linkContainer {
        flex-direction: column;
    }
    
    .modal-buttons {
        flex-direction: column;
    }
    
    .modal-btn {
        width: 100%;
    }
}

/* Scrollbar personalizado */
.files-list::-webkit-scrollbar {
    width: 8px;
}

.files-list::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 4px;
}

.files-list::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.3);
    border-radius: 4px;
}

.files-list::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.5);
}
EOF
    
    echo "   ├── 🎨 Estilos CSS creados"
    echo "   └── ✅ Aplicación completa creada"
}

# Función para instalar dependencias Python
install_python_deps() {
    echo ""
    echo "🐍 Instalando dependencias de Python..."
    pip3 install -r requirements.txt -q &>/dev/null
    if [ $? -eq 0 ]; then
        echo "   └── ✅ Dependencias de Python instaladas"
    else
        echo "   └── ❌ Error instalando dependencias de Python"
        exit 1
    fi
}

# Función para configurar el servidor
setup_server() {
    echo ""
    echo "🚀 Configurando servidor..."
    
    # Solicitar puerto
    read -p '🌐 Puerto (por defecto 5001): ' -e -i 5001 port
    
    # Iniciar servidor en screen
    screen -dmS downloader python3 main.py $port
    
    if [ $? -eq 0 ]; then
        echo "   ├── ✅ Servidor iniciado en puerto $port"
        echo "   └── 📱 Session de screen: 'downloader'"
    else
        echo "   └── ❌ Error iniciando el servidor"
        exit 1
    fi
}

# Función para mostrar información final
show_final_info() {
    echo ""
    echo "🎉 ¡Instalación completada exitosamente!"
    echo "=============================================="
    echo ""
    echo "📱 INFORMACIÓN DE ACCESO:"
    echo "   ├── URL Local: http://localhost:$port"
    echo "   ├── URL Pública: http://$DOMAIN:$port"
    echo "   └── IP Pública: http://$(curl -4s https://api.ipify.org 2>/dev/null || echo 'Error obteniendo IP'):$port"
    echo ""
    echo "🔧 COMANDOS ÚTILES:"
    echo "   ├── Ver logs: screen -r downloader"
    echo "   ├── Detener servidor: screen -S downloader -X quit"
    echo "   ├── Reiniciar: cd $PROJECT_NAME && screen -dmS downloader python3 main.py $port"
    echo "   └── Ver archivos: ls $PROJECT_NAME/$UPLOAD_DIR/"
    echo ""
    echo "✨ FUNCIONALIDADES:"
    echo "   ├── 📱 Subida de archivos APK con drag & drop"
    echo "   ├── 🗃️ Almacenamiento persistente de archivos"
    echo "   ├── 🔄 Gestión de duplicados (reemplazar/mantener ambos)"
    echo "   ├── 📋 Lista de archivos con información detallada"
    echo "   ├── 🗑️ Eliminación individual y masiva de archivos"
    echo "   └── 🎨 Interfaz moderna y responsive"
    echo ""
    echo "🔗 Desarrollado por @JHServices"
    echo "   └── GitHub: https://github.com/JJSecureVPN"
}

# Función principal
main() {
    install_dependencies
    create_app
    install_python_deps
    setup_server
    show_final_info
}

# Ejecutar instalación
main

# Mantener el script activo por un momento para mostrar los mensajes
sleep 2
