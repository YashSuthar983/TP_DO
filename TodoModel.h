#ifndef TODOMODEL_H
#define TODOMODEL_H

#include "qabstractitemmodel.h"
#include <QAbstractListModel>
#include <QList>
#include <QVariantMap>
#include <QString>

class TodoModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        TextRole = Qt::UserRole + 1,
        DoneRole
    };

    TodoModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addTask(const QString &text, bool done = false);
    Q_INVOKABLE void removeTask(int index);
    Q_INVOKABLE void setDone(int index, bool done);

    Q_INVOKABLE void saveToFile(const QString &filePath);
    Q_INVOKABLE void loadFromFile(const QString &filePath);

private:
    QList<QVariantMap> m_items;
};

class SettingsModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int expandedWidth READ expandedWidth WRITE setExpandedWidth NOTIFY expandedWidthChanged)
    Q_PROPERTY(int winHeight READ winHeight WRITE setWinHeight NOTIFY winHeightChanged)
public:
    SettingsModel(QObject *parent = nullptr);
    int expandedWidth() const { return m_expandedWidth; }
    void setExpandedWidth(int expandedWidth);
    int winHeight() const { return m_winHeight; }
    void setWinHeight(int winHeight);

    Q_INVOKABLE void saveToFile(const QString &filePath);
    Q_INVOKABLE void loadFromFile(const QString &filePath);

signals:
    void expandedWidthChanged();
    void winHeightChanged();
private:
    int m_expandedWidth;
    int m_winHeight;
};

#endif // TODOMODEL_H
