#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include "TodoModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    TodoModel tasksModel;
    TodoModel historyModel;
    SettingsModel settingsModel;

    tasksModel.loadFromFile("tasks.json");
    historyModel.loadFromFile("history.json");
    settingsModel.loadFromFile("settings.json");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("tasksModel", &tasksModel);
    engine.rootContext()->setContextProperty("historyModel", &historyModel);
    engine.rootContext()->setContextProperty("settingsModel", &settingsModel);
    const QUrl url(QStringLiteral("qml/Main.qml"));

    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    QObject::connect(&app, &QGuiApplication::aboutToQuit, [&]() {
        tasksModel.saveToFile("tasks.json");
        historyModel.saveToFile("history.json");
        settingsModel.saveToFile("settings.json");
    });

    return app.exec();
}
