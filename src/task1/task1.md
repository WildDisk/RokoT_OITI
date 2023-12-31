# Задача 1 - Знакомство с Git

## Задача

Первое задание - знакомство с git.

Разобраться как работает. Завести на общедоступном (ну или приватном - для нас с тобой, милый мой) проект, где будут лежать последующие наработки.

В первой репе описать базовые команды для работы с гитом из консоли. Формат описания - md.
Прислать мне merge request (или аналог) на review.

___

* [Создание репы](#создание-репы)
* [Смена ветки](#создаём-и-меняем-используемую-ветку-репозитория)
* [Индексирование](#индексирование-контента)
* [Чек регистрации изменений](#проверка-регистрации-изменений)
* [Коммит](#коммит)
* [Пуш](#пуш)
##
* [Конфликты](#конфликты)
* [Обновление](#обновляемся)
* [Мерджинг](#мердж)
* [Mergetool](#mergetool)

## Создание репы

### …or create a new repository on the command line
```bash
echo "# RokoT_OITI" >> README.md
git init
git add README.md
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/WildDisk/RokoT_OITI.git
git push -u origin main
```

### …or push an existing repository from the command line
```bash
git remote add origin https://github.com/WildDisk/RokoT_OITI.git
git branch -M main
git push -u origin main
```

## Создаём и меняем используемую ветку репозитория
```bash
git checkout -b develop
```

## Индексирование контента
```bash
git add --all
```

## Проверка регистрации изменений
```bash
git status
```
```
Текущая ветка: develop
Изменения, которые будут включены в коммит:
  (используйте «git restore --staged <файл>...», чтобы убрать из индекса)
        изменено:      ../README.md
        изменено:      task1.md
```

## Коммит
```bash
git commit -m "Task 1 - Знакомство с Git"
```

## Пуш
```bash
git push origin develop
```

---

## Конфликты

### Обновляемся
```bash
git pull --rebase
```

### Мердж
```bash
git merge main
```
По сути принимаем изменение из корня ибо данный вариант был более валидный

### Mergetool
```bash
git mergetool
```
Используем `meld` из-за того что Auto-merge не сработал, разрешаем конфликт руками

### Коммит и Пуш
Тут по классике `git commit && git push`

---
[Вначало](#задача-1---знакомство-с-git) | [К следующей](../task2/task2.md)