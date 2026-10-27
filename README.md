# LudumDare43
My game for Ludum Dare 43 (https://ldjam.com/events/ludum-dare/43)

https://ldjam.com/events/ludum-dare/43/ludumcoin

Direct link: https://ater.me/ld43/

![screenshot](https://static.jam.vg/raw/8ff/81/z/1c5ba.png)

## Сборка для веба (HTML5)

Нужен Linux-snap Solar2D (консольный билдер в нём HTML5 не умеет, сборка идёт через GUI симулятора):

```sh
curl -LO https://github.com/coronalabs/corona/releases/download/3711/Solar2D-Linux-2024.3711_amd64.snap
sudo snap install --dangerous --devmode ./Solar2D-Linux-2024.3711_amd64.snap
```

Дальше `./build-html5.sh`: он копирует проект в `~/ld43-html5/src` (snap видит только `$HOME`),
открывает симулятор и печатает, что ввести в диалоге `File → Build → HTML5` (`Ctrl+Alt+B`).
После закрытия симулятора результат лежит в `builds/ludumcoin.html5/`.

Запуск локально (с `file://` не работает, нужен http):

```sh
./build-html5.sh serve     # или: python3 -m http.server -d builds/ludumcoin.html5 8000
```
