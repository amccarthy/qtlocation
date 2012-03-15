/****************************************************************************
**
** Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/
**
** This file is part of the QtLocation module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation and
** appearing in the file LICENSE.LGPL included in the packaging of this
** file. Please review the following information to ensure the GNU Lesser
** General Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights. These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of this
** file. Please review the following information to ensure the GNU General
** Public License version 3.0 requirements will be met:
** http://www.gnu.org/copyleft/gpl.html.
**
** Other Usage
** Alternatively, this file may be used in accordance with the terms and
** conditions contained in a signed written agreement between you and Nokia.
**
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/
#ifndef QGEOMAPDATA_P_H
#define QGEOMAPDATA_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include <QObject>

#include "qgeocameradata_p.h"
#include "qgeomaptype.h"
#include "qgeocoordinateinterpolator_p.h"
#include "qgeocoordinateinterpolator_p.h"

QT_BEGIN_NAMESPACE

class QGeoCoordinate;

class QGeoMappingManagerEngine;

class QGeoMapDataPrivate;
class MapItem;
class QGeoMapController;
class QGeoCameraCapabilities;

class QGLCamera;
class QGLPainter;
class QGeoMap;

class QPointF;

class Q_LOCATION_EXPORT QGeoMapData : public QObject
{
    Q_OBJECT
public:
    QGeoMapData(QGeoMappingManagerEngine *engine, QObject *parent = 0);
    virtual ~QGeoMapData();

    QGeoMapController* mapController();

    QGLCamera* glCamera() const;
    virtual void paintGL(QGLPainter *painter) = 0;

    void resize(int width, int height);
    int width() const;
    int height() const;

    void setCameraData(const QGeoCameraData &cameraData);
    QGeoCameraData cameraData() const;

    void setActiveMapType(const QGeoMapType mapType);
    const QGeoMapType activeMapType() const;

    QSharedPointer<QGeoCoordinateInterpolator> coordinateInterpolator();

    virtual QGeoCoordinate screenPositionToCoordinate(const QPointF &pos, bool clipToViewport = true) const = 0;
    virtual QPointF coordinateToScreenPosition(const QGeoCoordinate &coordinate, bool clipToViewport = true) const = 0;

    QString pluginString();
    QGeoCameraCapabilities cameraCapabilities();

protected:
    void setCoordinateInterpolator(QSharedPointer<QGeoCoordinateInterpolator> interpolator);
    QGeoMappingManagerEngine *engine();

    virtual void mapResized(int width, int height) = 0;
    virtual void changeCameraData(const QGeoCameraData &oldCameraData) = 0;
    virtual void changeActiveMapType(const QGeoMapType mapType) = 0;

public Q_SLOTS:
    void update();

Q_SIGNALS:
    void cameraDataChanged(const QGeoCameraData &cameraData);
    void updateRequired();
    void activeMapTypeChanged();

private:
    QGeoMapDataPrivate *d_ptr;
    Q_DECLARE_PRIVATE(QGeoMapData)
};

QT_END_NAMESPACE

#endif // QGEOMAP_P_H