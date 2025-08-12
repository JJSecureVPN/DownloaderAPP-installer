# 🚀 DownloaderAPP - Instalador Público

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/JJSecureVPN/DownloaderAPP-installer)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Ubuntu%20%7C%20Debian-lightgrey.svg)](#)
[![Domain](https://img.shields.io/badge/domain-vps.jhservices.com.ar-orange.svg)](#)

> **Sistema avanzado de subida de archivos APK con gestión persistente y interfaz moderna**

## ✨ Características Principales

### 🔄 **Sistema de Gestión Persistente**
- **Almacenamiento permanente**: Los archivos no se eliminan automáticamente
- **Gestión de duplicados**: Modal interactivo con opciones de resolución
- **Control total**: Elimina archivos individualmente o en lote

### 📱 **Interfaz Moderna**
- **Drag & Drop**: Arrastra archivos directamente al navegador
- **Responsive**: Optimizado para móviles y escritorio
- **Animaciones**: Efectos visuales suaves y profesionales
- **Tema moderno**: Gradientes y efectos de cristal

### 🛠️ **API REST Completa**
- `GET /files` - Lista todos los archivos disponibles
- `POST /upload` - Subir archivo con gestión de duplicados
- `DELETE /delete/<filename>` - Eliminar archivo específico
- `POST /clear` - Limpiar todos los archivos
- `GET /download/<filename>` - Descargar archivo

### 🔒 **Gestión de Duplicados**
Cuando subes un archivo que ya existe, obtienes 3 opciones:
- **🔄 Reemplazar**: Sobrescribe el archivo existente
- **📁 Mantener ambos**: Guarda con timestamp único
- **❌ Cancelar**: Cancela la operación

## 🚀 Instalación Rápida

### Método 1: Una línea (Recomendado)
```bash
sudo bash <(curl -s https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh)
```

### Método 2: Descarga y ejecuta
```bash
wget https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh
sudo bash install.sh
```

### Método 3: Con curl
```bash
curl -O https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh
sudo bash install.sh
```

## 📋 Requisitos del Sistema

- **OS**: Linux (Ubuntu 18.04+, Debian 9+, CentOS 7+)
- **Python**: 3.6 o superior
- **Permisos**: Root/sudo
- **Memoria**: Mínimo 512MB RAM
- **Espacio**: 100MB libres

## 🎯 Proceso de Instalación

El instalador automático realizará:

1. **📦 Instalación de dependencias**
   - Git, Python3, pip3, screen, curl

2. **📁 Creación del proyecto**
   - Estructura completa de directorios
   - Archivos Python con toda la lógica
   - Templates HTML y CSS modernos

3. **🐍 Configuración de Python**
   - Instalación de Flask y Gevent
   - Configuración del entorno virtual

4. **🚀 Inicio del servidor**
   - Configuración del puerto personalizado
   - Ejecución en screen session
   - URLs de acceso automáticas

## 🔧 Gestión del Servidor

### Comandos Básicos
```bash
# Ver logs del servidor
screen -r downloader

# Detener servidor
screen -S downloader -X quit

# Reiniciar servidor
cd DownloaderAPP
screen -dmS downloader python3 main.py 5001

# Ver archivos subidos
ls DownloaderAPP/uploads/
```

### Cambiar Puerto
```bash
# Detener servidor actual
screen -S downloader -X quit

# Iniciar en nuevo puerto (ejemplo: 8080)
cd DownloaderAPP
screen -dmS downloader python3 main.py 8080
```

## 🌐 URLs de Acceso

Después de la instalación, accede a:

- **URL Local**: `http://localhost:PUERTO`
- **URL con Dominio**: `http://vps.jhservices.com.ar:PUERTO`
- **URL con IP Pública**: `http://TU_IP_PUBLICA:PUERTO`

## 📱 Uso de la Aplicación

### Subir Archivos
1. Arrastra un archivo APK al área de subida
2. O haz clic para seleccionar desde el explorador
3. Si el archivo existe, elige qué hacer en el modal
4. Copia el enlace de descarga generado

### Gestionar Archivos
- **Ver lista**: Se muestra automáticamente si hay archivos
- **Copiar enlace**: Botón 📋 junto a cada archivo
- **Descargar**: Botón ⬇️ para descarga directa
- **Eliminar**: Botón 🗑️ para eliminar específico
- **Limpiar todo**: Botón para eliminar todos los archivos

## 🛡️ Seguridad

- ✅ Solo acepta archivos `.apk`
- ✅ Validación de tipos de archivo
- ✅ Sanitización de nombres de archivo
- ✅ Control de duplicados
- ✅ Gestión de errores completa

## 🔄 Actualización

Para actualizar a la última versión:

```bash
# Detener servidor
screen -S downloader -X quit

# Ejecutar instalador nuevamente
sudo bash <(curl -s https://raw.githubusercontent.com/JJSecureVPN/DownloaderAPP-installer/main/install.sh)
```

## 🐛 Solución de Problemas

### Error de permisos
```bash
sudo chown -R $USER:$USER DownloaderAPP/
chmod +x DownloaderAPP/main.py
```

### Puerto ocupado
```bash
# Verificar qué usa el puerto
sudo netstat -tulpn | grep :5001

# Cambiar a otro puerto
cd DownloaderAPP
screen -dmS downloader python3 main.py 8080
```

### Dependencias faltantes
```bash
sudo apt update
sudo apt install python3 python3-pip git screen curl -y
pip3 install Flask==2.3.3 gevent==23.7.0
```

## 📞 Soporte

- **GitHub Issues**: [Reportar problema](https://github.com/JJSecureVPN/DownloaderAPP-installer/issues)
- **Desarrollador**: @JHServices
- **Dominio**: vps.jhservices.com.ar

## 📝 Changelog

### v2.0 (Actual)
- ✨ Sistema de gestión de archivos persistente
- ✨ Modal para resolución de duplicados
- ✨ API REST completa
- ✨ Interfaz moderna con animaciones
- ✨ Gestión individual y masiva de archivos
- ✨ Información detallada de archivos (tamaño, fecha)
- ✨ Nomenclatura inteligente para duplicados

### v1.0
- 📱 Subida básica de archivos APK
- 🌐 Interfaz web simple
- 🔗 Generación de enlaces de descarga

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

<div align="center">

**🚀 Desarrollado con ❤️ por [@JHServices](https://github.com/JJSecureVPN)**

[![GitHub](https://img.shields.io/badge/GitHub-JJSecureVPN-blue?style=flat-square&logo=github)](https://github.com/JJSecureVPN)
[![Domain](https://img.shields.io/badge/Domain-vps.jhservices.com.ar-orange?style=flat-square&logo=internet-explorer)](http://vps.jhservices.com.ar)

</div>
