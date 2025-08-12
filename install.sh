url='https://github.com/JJSecureVPN/DownloaderAPP.git'
dependencies=(git python3 pip3 screen)

for dependence in "${dependencies[@]}"; do
    if ! command -v $dependence >/dev/null 2>&1; then
        echo "Instalando $dependence..."
        apt install $dependence -y &>/dev/null
    fi
done

git clone $url &>/dev/null
cd DownloaderAPP
mkdir uploads

pip3 install -r requirements.txt &>/dev/null
read -p 'Puerto: ' -e -i 5001 port
screen -dmS downloader python3 main.py $port

echo "¡Instalado con éxito!"
echo "Accede a http://$(curl -4s https://api.ipify.org):$port"
