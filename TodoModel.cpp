#include "TodoModel.h"
#include "qabstractitemmodel.h"
#include "qnamespace.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QDir>

TodoModel::TodoModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int TodoModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant TodoModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_items.size())
        return QVariant();

    const QVariantMap &item = m_items.at(index.row());
    switch (role) {
    case TextRole:
        return item.value("text");
    case DoneRole:
        return item.value("done");
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TodoModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TextRole] = "text";
    roles[DoneRole] = "done";
    return roles;
}

void TodoModel::addTask(const QString &text, bool done)
{
    beginInsertRows(QModelIndex(), 0, 0);
    QVariantMap item;
    item["text"] = text;
    item["done"] = done;
    m_items.prepend(item);
    endInsertRows();
}

void TodoModel::removeTask(int index)
{
    if (index < 0 || index >= m_items.size())
        return;
    beginRemoveRows(QModelIndex(), index, index);
    m_items.removeAt(index);
    endRemoveRows();
}

void TodoModel::setDone(int index, bool done)
{
    if (index < 0 || index >= m_items.size())
        return;
    m_items[index]["done"] = done;
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {DoneRole});
}

void TodoModel::moveTask(int from, int to)
{
    if (from < 0 || from >= m_items.size() || to < 0 || to >= m_items.size() || from == to)
        return;
    
    int dest = to;
    if (from < to) {
        dest = to + 1;
    }
    
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), dest);
    m_items.move(from, to);
    endMoveRows();
}

int TodoModel::count() const
{
    return m_items.size();
}

Qt::DropActions TodoModel::supportedDropActions() const
{
    return Qt::MoveAction;
}

Qt::ItemFlags TodoModel::flags(const QModelIndex &index) const
{
    Qt::ItemFlags f= QAbstractListModel::flags(index);
    if(index.isValid())
        f |= Qt::ItemIsDragEnabled | Qt::ItemIsDropEnabled | Qt::ItemIsSelectable;
    else 
        f |= Qt::ItemIsDropEnabled;
    return f;
}

void TodoModel::saveToFile(const QString &filePath)
{
    QJsonArray jsonArray;
    for (const QVariantMap &item : m_items) {
        QJsonObject obj;
        obj["text"] = item["text"].toString();
        obj["done"] = item["done"].toBool();
        jsonArray.append(obj);
    }
    QJsonDocument doc(jsonArray);
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
}

void TodoModel::loadFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return;
    QByteArray data = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray())
        return;
    QJsonArray jsonArray = doc.array();
    beginResetModel();
    m_items.clear();
    for (const QJsonValue &value : jsonArray) {
        if (value.isObject()) {
            QJsonObject obj = value.toObject();
            QVariantMap item;
            item["text"] = obj["text"].toString();
            item["done"] = obj["done"].toBool();
            m_items.append(item);
        }
    }
    endResetModel();
}

SettingsModel::SettingsModel(QObject *parent)
    : QObject(parent), m_expandedWidth(400), m_winHeight(600)
{
}

void SettingsModel::setExpandedWidth(int expandedWidth)
{
    if (m_expandedWidth != expandedWidth) {
        m_expandedWidth = expandedWidth;
        emit expandedWidthChanged();
    }
}

void SettingsModel::setWinHeight(int winHeight)
{
    if (m_winHeight != winHeight) {
        m_winHeight = winHeight;
        emit winHeightChanged();
    }
}

void SettingsModel::saveToFile(const QString &filePath)
{
    QJsonArray jsonArray;
    QJsonObject obj;
    obj["Height"] = m_winHeight;
    obj["Width"] = m_expandedWidth;
    jsonArray.append(obj);
    QJsonDocument doc(jsonArray);
    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
}

void SettingsModel::loadFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return;
    QByteArray data = file.readAll();
    file.close();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray())
        return;
    QJsonArray jsonArray = doc.array();
    if (jsonArray.isEmpty())
        return;
    QJsonObject obj = jsonArray[0].toObject();
    m_winHeight = obj["Height"].toInt();
    m_expandedWidth = obj["Width"].toInt();
}
