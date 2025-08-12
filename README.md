# 🚀 DownloaderAPP - Instalador

Un script de instalación automática para **DownloaderAPP**, una aplicación web para subir y compartir archivos APK de manera fácil y rápida.

![APK Uploader](https://img.shields.io/badge/APK-Uploader-green.svg)
![Python](https://img.shields.io/badge/Python-3.6+-blue.svg)
![Flask](https://img.shields.io/badge/Flask-Web%20App-red.svg)
![Linux](https://img.shields.io/badge/OS-Linux-yellow.svg)

## 📱 ¿Qué es DownloaderAPP?

**DownloaderAPP** es una aplicación web moderna que permite:

- ✅ **Subir archivos APK** con drag & drop
- ✅ **Generar enlaces de descarga** automáticamente  
- ✅ **Interfaz responsive** y moderna
- ✅ **Gestión automática** de archivos
- ✅ **Fácil instalación** con un comando

## 🔧 Instalación Rápida

### Una sola línea de comando:

```bash
bash <(curl -sL https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh)
```

### ¿Qué hace el instalador?

1. 🔍 **Verifica dependencias** (Python3, pip, git)
2. 📦 **Instala automáticamente** lo que falta
3. 📁 **Crea la estructura** de archivos necesaria
4. 🐍 **Instala librerías** de Python (Flask, Gevent)
5. ⚙️  **Configura el servidor** según tus preferencias
6. 🚀 **Inicia la aplicación** automáticamente

## 📋 Requisitos del Sistema

- **Sistema Operativo:** Linux (Ubuntu, Debian, CentOS, etc.)
- **Python:** 3.6 o superior
- **Permisos:** sudo (para instalar dependencias)
- **Red:** Conexión a internet para descarga

## 🎯 Características

### Interfaz Moderna
- 🎨 **Diseño responsive** adaptable a cualquier dispositivo
- 🌙 **Tema oscuro** elegante y profesional
- ✨ **Animaciones suaves** y transiciones
- 📱 **Iconos intuitivos** para mejor UX

### Funcionalidades
- 📂 **Drag & Drop** - Arrastra archivos directamente
- 🔗 **Enlaces automáticos** - Genera URLs de descarga
- 📋 **Copiar enlace** - Un clic para copiar al portapapeles
- 🗂️  **Gestión inteligente** - Limpia archivos anteriores
- ⚡ **Carga rápida** - Indicadores de progreso

### Tecnología
- 🐍 **Python 3** - Backend robusto
- 🌐 **Flask** - Framework web ligero
- ⚡ **Gevent** - Servidor WSGI de alto rendimiento
- 🎨 **CSS3** - Estilos modernos con gradientes
- 📱 **JavaScript** - Interactividad del cliente

## 🚀 Uso

### 1. Accede a la aplicación
```
http://tu-servidor:5001
```

### 2. Sube tu archivo APK
- Arrastra el archivo APK al área designada
- O haz clic para seleccionar desde el explorador

### 3. Obtén el enlace
- La aplicación genera automáticamente un enlace de descarga
- Copia el enlace con un solo clic
- ¡Comparte donde necesites!

## ⚙️ Configuración Avanzada

### Cambiar Puerto
```bash
python3 main.py 8080
```

### Ejecutar en Segundo Plano
```bash
# Con screen
screen -dmS downloaderapp python3 main.py 5001

# Con nohup
nohup python3 main.py 5001 > server.log 2>&1 &
```

### Detener el Servidor
```bash
# Si usas screen
screen -S downloaderapp -X quit

# Si usas nohup
pkill -f "python3 main.py"

# Manual
Ctrl + C (en terminal activo)
```

## 🔒 Seguridad

- ✅ **Validación de archivos** - Solo acepta archivos .apk
- ✅ **Limpieza automática** - Elimina archivos anteriores
- ✅ **Sin persistencia** - Los archivos no se almacenan indefinidamente
- ⚠️  **Uso recomendado** - Redes privadas o VPN

## 🛠️ Solución de Problemas

### Error: "No se puede conectar"
```bash
# Verificar que el puerto esté abierto
sudo ufw allow 5001

# O cambiar puerto
python3 main.py 8080
```

### Error: "Dependencias faltantes"
```bash
# Instalar manualmente
sudo apt update
sudo apt install python3 python3-pip
pip3 install flask gevent
```

### Reinstalar desde cero
```bash
rm -rf DownloaderAPP
bash <(curl -sL https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh)
```

## 📊 Estructura del Proyecto

```
DownloaderAPP/
├── main.py                 # Servidor principal
├── requirements.txt        # Dependencias Python
├── uploads/               # Directorio de archivos subidos
└── app/
    ├── __init__.py        # Inicialización Flask
    ├── routes/
    │   ├── __init__.py
    │   └── index.py       # Rutas principales
    ├── static/
    │   └── css/
    │       └── style.css  # Estilos de la aplicación
    └── templates/
        └── index.html     # Interfaz principal
```

## 🤝 Contribuir

Este es un proyecto de código abierto. Si quieres contribuir:

1. 🐛 **Reporta bugs** en los issues
2. 💡 **Sugiere mejoras** 
3. 🔧 **Envía pull requests**
4. ⭐ **Da una estrella** si te gusta el proyecto

## 📞 Soporte

- 💬 **Telegram:** [@JHServices](https://t.me/JHServices)
- 📧 **Issues:** [GitHub Issues](https://github.com/JJSecureVPN/DownloaderAPP-installer/issues)
- 🌐 **Web:** Próximamente...

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.

## 🏷️ Versión

**v1.0.0** - Versión inicial estable

---

<div align="center">
  
**📱 DownloaderAPP - La forma más fácil de compartir APKs 🚀**

Creado con ❤️ por [@JHServices](https://t.me/JHServices)

</div>
