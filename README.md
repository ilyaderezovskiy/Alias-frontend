# Alias-frontend
iOS Homework 2

Промышленная iOS-разработка
ДЗ #2.
Создание фронтенда игры «Шляпа» («Alias»)
Дерезовский Илья БПИ206

1. Запуск сервера
a. docker run --name alias -e POSTGRES_DB=alias_database -e POSTGRES_USER=alias_username -e POSTGRES_PASSWORD=alias_password -p 5432:5432 -d postgres
(база данных: alias_database ,
пользователь:alias_username ,
пароль: alias_password)
b. Запуск backend-части приложения: Alias

2. Реализованы все пункты функционала кроме 15, 19 и виджета. При работе с приложением возникают трудности, когда в приложении долго подгружаются данные с сервера (не обновляются) – приходится открывать/закрывать странички приложения, но в бд данные обновляются моментально

3. Демонстрация работы приложения: https://disk.yandex.ru/i/6YjemH0eHKIATg
