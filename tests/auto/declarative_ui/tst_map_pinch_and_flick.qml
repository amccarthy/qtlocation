/****************************************************************************
**
** Copyright (C) 2012 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the test suite of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtTest 1.0
import QtLocation 5.0
import QtLocation.test 5.0

Item {
    // General-purpose elements for the test:
    id: page
    width: 100
    height: 100
    Plugin { id: testPlugin; name: "qmlgeo.test.plugin"; allowExperimental: true }

    property variant coordinate1: QtLocation.coordinate(10, 11)

    Map {
        id: map
        plugin: testPlugin
        center: coordinate1;
        zoomLevel: 9;
        anchors.fill: page
        x:0; y:0
        property variant lastPinchEvent: null
        property bool rejectPinch: false
        gesture.onPinchStarted: {
            map.lastPinchEvent = pinch;
            if (rejectPinch)
                pinch.accepted = false;
            //console.log('Pinch got started, point1: ' + pinch.point1 + ' point2: ' + pinch.point2 + ' angle: ' + pinch.angle)
        }
        gesture.onPinchUpdated: {
            map.lastPinchEvent = pinch;
            //console.log('Pinch got updated, point1: ' + pinch.point1 + ' point2: ' + pinch.point2 + ' angle: ' + pinch.angle)
        }
        gesture.onPinchFinished: {
            map.lastPinchEvent = pinch;
        }
        property real flickStartedLatitude
        property real flickStartedLongitude
        property bool disableFlickOnStarted: false
        property bool disableFlickOnMovementStarted: false
        gesture.onPanStarted: {
            if (disableFlickOnMovementStarted)
                map.gesture.panEnabled = false
        }
        gesture.onFlickStarted: {
            flickStartedLatitude = map.center.latitude
            flickStartedLatitude = map.center.longitude
            if (disableFlickOnStarted)
                map.gesture.panEnabled = false
        }
    }
    SignalSpy {id: centerSpy; target: map; signalName: 'centerChanged'}
    SignalSpy {id: pinchStartedSpy; target: map.gesture; signalName: 'pinchStarted'}
    SignalSpy {id: pinchUpdatedSpy; target: map.gesture; signalName: 'pinchUpdated'}
    SignalSpy {id: pinchFinishedSpy; target: map.gesture; signalName: 'pinchFinished'}
    SignalSpy {id: pinchMaximumZoomLevelChangeSpy; target: map.gesture; signalName: 'maximumZoomLevelChangeChanged'}
    //SignalSpy {id: pinchMinimumZoomLevelSpy; target: map.gesture; signalName: 'minimumZoomLevelChanged'}
    //SignalSpy {id: pinchMaximumZoomLevelSpy; target: map.gesture; signalName: 'maximumZoomLevelChanged'}
    //SignalSpy {id: pinchMinimumRotationSpy; target: map.gesture; signalName: 'minimumRotationChanged'}
    //SignalSpy {id: pinchMaximumRotationSpy; target: map.gesture; signalName: 'maximumRotationChanged'}
    SignalSpy {id: pinchRotationFactorSpy; target: map.gesture; signalName: 'rotationFactorChanged'}
    SignalSpy {id: gestureEnabledSpy; target: map.gesture; signalName: 'enabledChanged'}
    SignalSpy {id: pinchActiveSpy; target: map.gesture; signalName: 'pinchActiveChanged'}
    SignalSpy {id: pinchActiveGesturesSpy; target: map.gesture; signalName: 'activeGesturesChanged'}
    SignalSpy {id: mapZoomLevelSpy; target: map; signalName: 'zoomLevelChanged'}
    SignalSpy {id: mapBearingSpy; target: map; signalName: 'bearingChanged'}
    SignalSpy {id: flickDecelerationSpy; target: map.gesture; signalName: 'flickDecelerationChanged'}
    SignalSpy {id: movementStoppedSpy; target: map.gesture; signalName: 'movementStopped'}
    SignalSpy {id: flickStartedSpy; target: map.gesture; signalName: 'flickStarted'}
    SignalSpy {id: flickFinishedSpy; target: map.gesture; signalName: 'flickFinished'}

    // From QtLocation.test plugin
    PinchGenerator {
        id: pinchGenerator
        anchors.fill: parent
        target: map
        enabled: false
    }

    TestCase {
        when: windowShown
        name: "Map pinch"

        function clear_data() {
            centerSpy.clear()
            pinchStartedSpy.clear()
            pinchUpdatedSpy.clear()
            pinchFinishedSpy.clear()
            pinchMaximumZoomLevelChangeSpy.clear()
            //pinchMinimumZoomLevelSpy.clear()
            //pinchMaximumZoomLevelSpy.clear()
            //pinchMinimumRotationSpy.clear()
            //pinchMaximumRotationSpy.clear()
            pinchRotationFactorSpy.clear()
            gestureEnabledSpy.clear()
            pinchActiveSpy.clear()
            pinchActiveGesturesSpy.clear()
            mapZoomLevelSpy.clear()
            mapBearingSpy.clear()
            flickDecelerationSpy.clear()
            movementStoppedSpy.clear()
            flickStartedSpy.clear()
            flickFinishedSpy.clear()
        }

        function test_a_basic_properties() { // a to excecute first
            clear_data()

            compare(map.gesture.enabled, true)
            map.gesture.enabled = false
            compare(gestureEnabledSpy.count, 1)
            compare(map.gesture.enabled, false)
            map.gesture.enabled = false
            compare(gestureEnabledSpy.count, 1)
            compare(map.gesture.enabled, false)
            map.gesture.enabled = true
            compare(gestureEnabledSpy.count, 2)
            compare(map.gesture.enabled, true)

            compare(map.gesture.isPinchActive, false)

            verify(map.gesture.activeGestures & MapGestureArea.ZoomGesture)
            verify(!(map.gesture.activeGestures & MapGestureArea.RotationGesture))
            verify(!(map.gesture.activeGestures & MapGestureArea.TiltGesture))
            map.gesture.activeGestures = MapGestureArea.NoGesture
            compare(map.gesture.activeGestures, MapGestureArea.NoGesture)
            compare(pinchActiveGesturesSpy.count, 1)
            map.gesture.activeGestures = MapGestureArea.NoGesture
            compare(map.gesture.activeGestures, MapGestureArea.NoGesture)
            compare(pinchActiveGesturesSpy.count, 1)
            map.gesture.activeGestures = MapGestureArea.ZoomGesture | MapGestureArea.RotationGesture
            compare(map.gesture.activeGestures, MapGestureArea.ZoomGesture | MapGestureArea.RotationGesture)
            compare(pinchActiveGesturesSpy.count, 2)
            map.gesture.activeGestures = MapGestureArea.RotationGesture
            compare(map.gesture.activeGestures, MapGestureArea.RotationGesture)
            compare(pinchActiveGesturesSpy.count, 3)
            map.gesture.activeGestures = MapGestureArea.ZoomGesture
            compare(map.gesture.activeGestures, MapGestureArea.ZoomGesture)
            compare(pinchActiveGesturesSpy.count, 4)

            /*
            compare(map.gesture.minimumZoomLevel, map.minimumZoomLevel)
            map.gesture.minimumZoomLevel = 5
            compare(pinchMinimumZoomLevelSpy.count, 1)
            compare(map.gesture.minimumZoomLevel, 5)
            map.gesture.minimumZoomLevel = -1 // too small
            map.gesture.minimumZoomLevel = 492 // too big
            compare(pinchMinimumZoomLevelSpy.count, 1)
            compare(map.gesture.minimumZoomLevel, 5)
            map.gesture.minimumZoomLevel = map.minimumZoomLevel
            compare(pinchMinimumZoomLevelSpy.count, 2)
            compare(map.gesture.minimumZoomLevel, map.minimumZoomLevel)

            compare(map.gesture.maximumZoomLevel, map.maximumZoomLevel)
            map.gesture.maximumZoomLevel = 9
            compare (pinchMaximumZoomLevelSpy.count, 1)
            compare(map.gesture.maximumZoomLevel, 9)
            map.gesture.maximumZoomLevel = -1 // too small
            map.gesture.maximumZoomLevel = 3234 // too big
            compare(pinchMaximumZoomLevelSpy.count, 1)
            compare(map.gesture.maximumZoomLevel, 9)
            map.gesture.maximumZoomLevel = map.maximumZoomLevel
            compare(pinchMaximumZoomLevelSpy.count, 2)
            compare(map.gesture.maximumZoomLevel, map.maximumZoomLevel)

            clear_data()
            map.gesture.minimumZoomLevel = 5  // ok
            map.gesture.maximumZoomLevel = 9  // ok
            map.gesture.minimumZoomLevel = 10 // bigger than max
            map.gesture.maximumZoomLevel = 4  // smaller than min
            compare (pinchMaximumZoomLevelSpy.count, 1)
            compare (pinchMinimumZoomLevelSpy.count, 1)
            compare(map.gesture.maximumZoomLevel, 9)
            compare(map.gesture.minimumZoomLevel, 5)
            map.gesture.minimumZoomLevel = map.minimumZoomLevel
            map.gesture.maximumZoomLevel = map.maximumZoomLevel
            */

            compare(map.gesture.maximumZoomLevelChange, 2)
            map.gesture.maximumZoomLevelChange = 4
            compare(pinchMaximumZoomLevelChangeSpy.count, 1)
            compare (map.gesture.maximumZoomLevelChange, 4)
            map.gesture.maximumZoomLevelChange = 4
            compare(pinchMaximumZoomLevelChangeSpy.count, 1)
            compare (map.gesture.maximumZoomLevelChange, 4)
            map.gesture.maximumZoomLevelChange = 11   // too big
            map.gesture.maximumZoomLevelChange = 0.01 // too small
            map.gesture.maximumZoomLevelChange = -1   // too small
            compare(pinchMaximumZoomLevelChangeSpy.count, 1)
            compare (map.gesture.maximumZoomLevelChange, 4)
            map.gesture.maximumZoomLevelChange = 2
            compare(pinchMaximumZoomLevelChangeSpy.count, 2)
            compare (map.gesture.maximumZoomLevelChange, 2)

            /*
            compare(map.gesture.minimumRotation, 0)
            map.gesture.minimumRotation = 10
            compare(pinchMinimumRotationSpy.count, 1)
            compare(map.gesture.minimumRotation, 10)
            map.gesture.minimumRotation = 10
            compare(pinchMinimumRotationSpy.count, 1)
            compare(map.gesture.minimumRotation, 10)
            map.gesture.minimumRotation = -1  // too small
            map.gesture.minimumRotation = 361 // too big
            compare(pinchMinimumRotationSpy.count, 1)
            compare(map.gesture.minimumRotation, 10)
            map.gesture.minimumRotation = 0
            compare(pinchMinimumRotationSpy.count, 2)
            compare(map.gesture.minimumRotation, 0)

            compare(map.gesture.maximumRotation, 45)
            map.gesture.maximumRotation = 55
            compare(pinchMaximumRotationSpy.count,1)
            compare(map.gesture.maximumRotation, 55)
            map.gesture.maximumRotation = 55
            compare(pinchMaximumRotationSpy.count,1)
            compare(map.gesture.maximumRotation, 55)
            map.gesture.maximumRotation = -1  // too small
            map.gesture.maximumRotation = 362 // too big
            compare(pinchMaximumRotationSpy.count,1)
            compare(map.gesture.maximumRotation, 55)
            map.gesture.maximumRotation = 45
            compare(pinchMaximumRotationSpy.count,2)
            compare(map.gesture.maximumRotation, 45)
            */

            compare(map.gesture.rotationFactor, 1)
            map.gesture.rotationFactor = 2
            compare(pinchRotationFactorSpy.count, 1)
            compare(map.gesture.rotationFactor, 2)
            map.gesture.rotationFactor = 2
            compare(pinchRotationFactorSpy.count, 1)
            compare(map.gesture.rotationFactor, 2)
            map.gesture.rotationFactor = -1 // too small
            map.gesture.rotationFactor = 6  // too big
            compare(pinchRotationFactorSpy.count, 1)
            compare(map.gesture.rotationFactor, 2)
            map.gesture.rotationFactor = 1
            compare(pinchRotationFactorSpy.count, 2)
            compare(map.gesture.rotationFactor, 1)
            /*
            compare(map.gesture.maximumTilt, 90)
            compare(map.gesture.minimumTilt, 0)
            compare(map.gesture.maximumTiltChange, 20)
            */

            compare(map.gesture.flickDeceleration, 2500)
            map.gesture.flickDeceleration = 2600
            compare(flickDecelerationSpy.count, 1)
            compare(map.gesture.flickDeceleration, 2600)
            map.gesture.flickDeceleration = 2600
            compare(flickDecelerationSpy.count, 1)
            compare(map.gesture.flickDeceleration, 2600)
            map.gesture.flickDeceleration = 400 // too small
            compare(flickDecelerationSpy.count, 2)
            compare(map.gesture.flickDeceleration, 500) // clipped to min
            map.gesture.flickDeceleration = 11000 // too big
            compare(flickDecelerationSpy.count, 3)
            compare(map.gesture.flickDeceleration, 10000) // clipped to max
        }

        function test_b_pinch_rotation() {
            map.gesture.activeGestures = MapGestureArea.RotationGesture
            map.gesture.rotationFactor = 1.0
            map.zoomLevel = 8
            compare(map.zoomLevel, 8)
            map.center.latitude = 10
            map.center.longitude = 11
            clear_data()
            compare(map.bearing, 0)
            // 1. basic ccw rotation
            pinchGenerator.pinch(
                        Qt.point(100, 0),   // point 1 from
                        Qt.point(50, 0),    // point 1 to
                        Qt.point(0, 100),   // point 2 from
                        Qt.point(50, 100)); // point 2 to
            tryCompare(pinchStartedSpy, "count", 1);
            wait(50);
            compare(pinchActiveSpy.count,1) // check that pinch is active
            compare(map.gesture.isPinchActive, true)
            wait(200);
            verify(pinchUpdatedSpy.count >= 5); // verify 'sane' number of updates received
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(pinchActiveSpy.count,2)
            compare(map.gesture.isPinchActive, false)
            compare(map.zoomLevel, 8) // mustn't change
            compare(mapBearingSpy.count, pinchUpdatedSpy.count)
            verify(map.bearing > 20 && map.bearing < 30) // roughly right
            var ccw_basic = map.bearing
            // 2. reverse the previous rotation (cw same amount)
            clear_data()
            pinchGenerator.pinch(
                        Qt.point(50, 0),
                        Qt.point(100, 0),
                        Qt.point(50, 100),
                        Qt.point(0, 100));
            tryCompare(pinchStartedSpy, "count", 1);
            wait(250);
            verify(pinchUpdatedSpy.count >= 5); // verify 'sane' number of updates received
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(pinchActiveSpy.count,2)
            compare(map.gesture.isPinchActive, false)
            compare(map.zoomLevel, 8) // mustn't change
            compare(mapBearingSpy.count, pinchUpdatedSpy.count)
            verify(map.bearing < 2 || map.bearing > 358) // roughly right
            // 3. set bearing manually on map and repeat the basic ccw rotation
            clear_data()
            map.bearing = 5
            compare(mapBearingSpy.count, 1)
            compare(map.bearing, 5)
            pinchGenerator.pinch(Qt.point(100, 0),Qt.point(50, 0),Qt.point(0, 100),Qt.point(50, 100));
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.bearing, ccw_basic + 5)
            map.bearing = 0
            // 4. manually setting bearing values
            clear_data()
            map.bearing = -1.5
            compare(mapBearingSpy.count, 1)
            compare(map.bearing, 358.5)
            map.bearing = -357.2
            compare(map.bearing, 2.8)
            map.bearing = 702.5
            compare(map.bearing, 343.5)
            map.bearing = -702.5
            compare(map.bearing, 16.5)
            map.bearing = 0
            // 5. rotation factor effects, repeat the basic ccw rotation
            map.gesture.rotationFactor = 2
            pinchGenerator.pinch(Qt.point(100, 0),Qt.point(50, 0),Qt.point(0, 100),Qt.point(50, 100));
            tryCompare(pinchFinishedSpy, "count", 1);
            verify (map.bearing >  (ccw_basic * 2 - 5)) // roughly right, hence the '5'
            map.bearing = 0
            map.gesture.rotationFactor = 0.5
            pinchGenerator.pinch(Qt.point(100, 0),Qt.point(50, 0),Qt.point(0, 100),Qt.point(50, 100));
            tryCompare(pinchFinishedSpy, "count", 2);
            verify (map.bearing > (ccw_basic / 2 - 1) && map.bearing < (ccw_basic / 2 + 1)) // roughly right, hence the '1'
            map.gesture.rotationFactor = 1.0
            map.bearing = 0
            // 6. manually changing the bearing during pinch rotation
            clear_data()
            pinchGenerator.pinch(Qt.point(100, 0),Qt.point(50, 0),Qt.point(0, 100),Qt.point(50, 100));
            tryCompare(pinchStartedSpy, "count", 1);

            tryCompare(pinchActiveSpy, "count",1) // check that pinch is active
            compare(map.gesture.isPinchActive, true)
            map.bearing += 100 // this will get overwritten
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.bearing, ccw_basic)
            // 7. test rotating past the '0' bearing
            clear_data()
            map.bearing = 350
            pinchGenerator.pinch(Qt.point(100, 0),Qt.point(50, 0),Qt.point(0, 100),Qt.point(50, 100));
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.bearing, ccw_basic - 10)
            // 8. sanity check the biggest rotation factor
            clear_data()
            map.gesture.rotationFactor = 5
            compare(map.gesture.rotationFactor, 5)
            map.bearing = 0
            pinchGenerator.pinch(Qt.point(100, 0),Qt.point(50, 0),Qt.point(0, 100),Qt.point(50, 100)); //ccw
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.bearing, ccw_basic * 5)
        }

        function test_a_flick() {
            clear_data()
            var i=0
            //var moveLatitude=0
            // few sanity checks
            map.gesture.activeGestures = MapGestureArea.PanGesture | MapGestureArea.FlickGesture;
            map.gesture.enabled = true
            map.gesture.panEnabled = true
            // to get maximum changes (robust autotest)
            map.gesture.flickDeceleration = 500
            map.zoomLevel = 0
            compare(map.center.latitude, coordinate1.latitude)
            compare(map.center.longitude, coordinate1.longitude)
            // 1. test basic flick down
            clear_data()
            map.center.latitude = 10
            map.center.longitude = 11
            mousePress(map, 0, 50)
            for (i=0; i < 50; i += 5) {
                wait(20)
                mouseMove(map, 0, (50 + i), 0, Qt.LeftButton);
            }
            mouseRelease(map, 0, (50 + i))

            // order of signals is: flickStarted, either order: (flickEnded, movementEnded)
            verify(map.center.latitude > 10) // latitude increases we are going 'up/north' (moving mouse down)
            var moveLatitude = map.center.latitude // store lat and check that flick continues
            tryCompare(flickStartedSpy, "count", 1)

            tryCompare(movementStoppedSpy, "count", 1)
            tryCompare(flickFinishedSpy, "count", 1)
            verify(map.center.latitude > moveLatitude)
            compare(map.center.longitude, 11) // should remain the same

            // 2. test basic flick up
            clear_data()
            map.center.latitude = 70
            map.center.longitude = 11
            mousePress(map, 10, 95)
            for (i=45; i > 0; i -= 5) {
                wait(20)
                mouseMove(map, 10, (50 + i), 0, Qt.LeftButton);
            }
            mouseRelease(map, 10, (50 + i))
            verify(map.center.latitude < 70)
            moveLatitude = map.center.latitude // store lat and check that flick continues
            tryCompare(flickStartedSpy, "count", 1)
            tryCompare(movementStoppedSpy, "count", 1)
            tryCompare(flickFinishedSpy, "count", 1)
            verify(map.center.latitude < moveLatitude)
            compare(map.center.longitude, 11) // should remain the same

            // 3. basic flick diagonal
            clear_data()
            map.center.latitude = 50
            map.center.longitude = 50
            mousePress(map, 0, 0)
            for (i=0; i < 50; i += 5) {
                wait(20)
                mouseMove(map, i, i, 0, Qt.LeftButton);
            }
            mouseRelease(map, i, i)
            verify(map.center.latitude > 50)
            verify(map.center.longitude < 50)
            moveLatitude = map.center.latitude
            var moveLongitude = map.center.longitude
            tryCompare(flickStartedSpy, "count", 1)
            tryCompare(movementStoppedSpy, "count", 1)
            tryCompare(flickFinishedSpy, "count", 1)
            verify(map.center.latitude > moveLatitude)
            verify(map.center.longitude < moveLongitude)
            var diagonalFlickResultLatitude = map.center.latitude
            var diagonalFlickResultLongitude = map.center.longitude
            // 4. test flicking while disabled
            clear_data()
            map.gesture.panEnabled = false
            map.center.latitude = 50
            map.center.longitude = 50
            for (i=0; i < 50; i += 5) {
                wait(20)
                mouseMove(map, i, i, 0, Qt.LeftButton);
            }
            mouseRelease(map, i, i)
            compare(flickStartedSpy.count, 0)
            compare(flickFinishedSpy.count, 0)
            compare(movementStoppedSpy.count, 0)
            map.gesture.panEnabled = true

            // 5. disable during flick: onFlickStarted
            clear_data()
            map.disableFlickOnStarted = true
            map.center.latitude = 50
            map.center.longitude = 50
            mousePress(map, 0, 0)
            for (i=0; i < 50; i += 5) {
                wait(20)
                mouseMove(map, i, i, 0, Qt.LeftButton);
            }
            mouseRelease(map, i, i)
            tryCompare(flickStartedSpy, "count", 1)
            verify(map.center.latitude > 50)
            tryCompare(flickStartedSpy, "count", 1)
            tryCompare(movementStoppedSpy, "count", 1)
            tryCompare(flickFinishedSpy, "count", 1)
            // compare that flick was interrupted (less movement than without interrupting)
            verify(diagonalFlickResultLatitude > map.center.latitude)
            verify(diagonalFlickResultLongitude < map.center.longitude)
            map.disableFlickOnStarted = false
            map.gesture.panEnabled = true

            // 6. disable during flick: onMovementStarted
            clear_data()
            map.disableFlickOnMovementStarted = true
            map.center.latitude = 50
            map.center.longitude = 50
            mousePress(map, 0, 0)
            for (i=0; i < 50; i += 5) {
                wait(20)
                mouseMove(map, i, i, 0, Qt.LeftButton);
            }
            mouseRelease(map, i, i)
            verify(map.center.latitude > 50)
            tryCompare(movementStoppedSpy, "count", 1)
            // compare that flick was interrupted (less movement than without interrupting)
            verify(diagonalFlickResultLatitude > map.center.latitude)
            verify(diagonalFlickResultLongitude < map.center.longitude)
            map.disableFlickOnMovementStarted = false
        }

        function test_pinch_zoom() {
            map.gesture.activeGestures = MapGestureArea.ZoomGesture
            map.zoomLevel = 9
            clear_data()
            // 1. typical zoom in
            map.gesture.maximumZoomLevelChange = 2
            compare(map.gesture.isPinchActive, false)
            pinchGenerator.pinch(
                        Qt.point(0,50),   // point1From
                        Qt.point(50,50),  // point1To
                        Qt.point(100,50), // point2From
                        Qt.point(50,50),  // point2To
                        40,               // interval between touch events (swipe1), default 20ms
                        40,               // interval between touch events (swipe2), default 20ms
                        10,               // number of touchevents in point1from -> point1to, default 10
                        10);              // number of touchevents in point2from -> point2to, default 10
            tryCompare(pinchStartedSpy, "count", 1);
            // check the pinch event data for pinchStarted
            compare(map.lastPinchEvent.center.x, 50)
            compare(map.lastPinchEvent.center.y, 50)
            compare(map.lastPinchEvent.angle, 0)
            verify((map.lastPinchEvent.point1.x > 0) && (map.lastPinchEvent.point1.x < 25))
            compare(map.lastPinchEvent.point1.y, 50)
            verify((map.lastPinchEvent.point2.x > 75) && (map.lastPinchEvent.point2.x < 100))
            compare(map.lastPinchEvent.point2.y, 50)
            compare(map.lastPinchEvent.accepted, true)
            compare(map.lastPinchEvent.pointCount, 2)
            tryCompare(pinchActiveSpy, "count", 1) // check that pinch is active
            compare(map.gesture.isPinchActive, true)
            wait(200)
            // check the pinch event data for pinchUpdated
            compare(map.lastPinchEvent.center.x, 50)
            compare(map.lastPinchEvent.center.y, 50)
            compare(map.lastPinchEvent.angle, 0)
            verify((map.lastPinchEvent.point1.x) > 25 &&  (map.lastPinchEvent.point1.x <= 50))
            compare(map.lastPinchEvent.point1.y, 50)
            verify((map.lastPinchEvent.point2.x) >= 50 && (map.lastPinchEvent.point2.x < 85))
            compare(map.lastPinchEvent.point2.y, 50)
            compare(map.lastPinchEvent.accepted, true)
            compare(map.lastPinchEvent.pointCount, 2)
            tryCompare(pinchFinishedSpy, "count", 1);
            // check the pinch event data for pinchFinished
            compare(map.lastPinchEvent.center.x, 50)
            compare(map.lastPinchEvent.center.y, 50)
            compare(map.lastPinchEvent.angle, 0)
            verify((map.lastPinchEvent.point1.x) > 35 &&  (map.lastPinchEvent.point1.x <= 50))
            compare(map.lastPinchEvent.point1.y, 50)
            verify((map.lastPinchEvent.point2.x) >= 50 &&  (map.lastPinchEvent.point2.x < 65))
            compare(map.lastPinchEvent.point2.y, 50)
            compare(map.lastPinchEvent.accepted, true)
            compare(map.lastPinchEvent.pointCount, 0)

            verify(pinchUpdatedSpy.count >= 5); // verify 'sane' number of updates received
            compare(pinchActiveSpy.count,2)
            compare(map.gesture.isPinchActive, false)
            compare(mapZoomLevelSpy.count, pinchUpdatedSpy.count)
            compare(map.zoomLevel, 8)
            // 2. typical zoom out
            clear_data();
            map.gesture.maximumZoomLevelChange = 2
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),
                                 Qt.point(50,50), Qt.point(100,50),
                                 40, 40, 10, 10);
            tryCompare(pinchStartedSpy, "count", 1);
            tryCompare(pinchFinishedSpy, "count", 1);
            verify(pinchUpdatedSpy.count >= 5); // verify 'sane' number of updates received
            compare(map.zoomLevel, 9)
            // 3. zoom in and back out (direction change during same pinch)
            clear_data();
            pinchGenerator.pinch(Qt.point(0,50), Qt.point(100,50),
                                 Qt.point(100,50),Qt.point(0,50),
                                 40, 40, 10, 10);
            tryCompare(pinchStartedSpy, "count", 1);
            tryCompare(pinchFinishedSpy, "count", 1);
            verify(pinchUpdatedSpy.count >= 5); // verify 'sane' number of updates received
            compare(map.zoomLevel, 9) // should remain the same
            // 4. typical zoom in with different change level
            clear_data();
            map.gesture.maximumZoomLevelChange = 4
            compare (map.gesture.maximumZoomLevelChange, 4)
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),
                                 Qt.point(100,50),Qt.point(50,50),
                                 40, 40, 10, 10);
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, 7)
            // 5. typical zoom out with different change level
            clear_data();
            map.gesture.maximumZoomLevelChange = 1
            compare (map.gesture.maximumZoomLevelChange, 1)
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),
                                 Qt.point(50,50), Qt.point(100,50),
                                 40, 40, 10, 10);
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, 7.5)

            // 6. try to zoom in below minimum zoom level
            /*
            clear_data()
            map.gesture.maximumZoomLevelChange = 4
            map.gesture.minimumZoomLevel = 7
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),Qt.point(100,50),Qt.point(50,50));
            wait(250);
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, 7) // would go to 5.5

            // 7. try to zoom out above maximum zoom level
            clear_data()
            map.gesture.maximumZoomLevelChange = 4
            map.gesture.maximumZoomLevel = 8
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),Qt.point(50,50), Qt.point(100,50));
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, 8) // would go to 9

            // 8. pinch when max and min are same
            clear_data()
            map.gesture.maximumZoomLevel = 8
            map.gesture.minimumZoomLevel = 8
            compare(map.gesture.maximumZoomLevel, 8)
            compare(map.gesture.minimumZoomLevel, 8)
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),Qt.point(100,50),Qt.point(50,50));
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, 8)

            // 9. pinch when max..min is not where map zoomLevel currently is
            clear_data()
            map.gesture.maximumZoomLevelChange = 4
            map.gesture.minimumZoomLevel = 4
            map.gesture.maximumZoomLevel = 6
            // first when above the zoom range
            map.zoomLevel = 10
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),Qt.point(50,50), Qt.point(100,50)); // zoom out
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, 6)
            map.zoomLevel = 10
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),Qt.point(100,50),Qt.point(50,50)); // zoom in
            tryCompare(pinchFinishedSpy, "count", 2);
            compare(map.zoomLevel, 6)
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),Qt.point(100,50),Qt.point(50,50)); // zoom in
            tryCompare(pinchFinishedSpy, "count", 3);
            compare(map.zoomLevel, 4)
            // when below the zoom range
            map.zoomLevel = 1
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),Qt.point(50,50), Qt.point(100,50)); // zoom out
            tryCompare(pinchFinishedSpy, "count", 4);
            compare(map.zoomLevel, 4)
            map.zoomLevel = 1
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),Qt.point(100,50),Qt.point(50,50)); // zoom in
            tryCompare(pinchFinishedSpy, "count", 5);
            compare(map.zoomLevel, 4)
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),Qt.point(50,50), Qt.point(100,50)); // zoom out
            tryCompare(pinchFinishedSpy, "count", 6);
            compare(map.zoomLevel, 6)
            map.gesture.minimumZoomLevel = map.minimumZoomLevel
            map.gesture.maximumZoomLevel = map.maximumZoomLevel
            */

            // 10. pinch while pinch area is disabled
            clear_data()
            map.gesture.enabled = false
            map.gesture.maximumZoomLevelChange = 2
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),
                                 Qt.point(50,50), Qt.point(100,50),
                                 40, 40, 10, 10);
            wait(200);
            compare(pinchActiveSpy.count, 0)
            compare(map.gesture.isPinchActive, false)
            compare(pinchStartedSpy.count, 0)
            compare(pinchUpdatedSpy.count, 0);
            compare(pinchFinishedSpy.count, 0);
            compare(map.zoomLevel, 7.5)
            pinchGenerator.stop()
            map.gesture.enabled = true

            // 11. pinch disabling during pinching
            clear_data()
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),
                                 Qt.point(50,50), Qt.point(100,50),
                                 40, 40, 10, 10);
            wait(300)
            map.gesture.enabled = false
            // check that pinch is active. then disable the pinch. pinch area should still process
            // as long as it is active
            compare(pinchActiveSpy.count,1)
            compare(map.gesture.isPinchActive, true)
            compare(pinchStartedSpy.count, 1)
            compare(pinchFinishedSpy.count, 0)
            var pinchupdates = pinchUpdatedSpy.count
            verify(pinchupdates > 0)
            tryCompare(pinchFinishedSpy, "count", 1)
            compare(pinchActiveSpy.count,2)
            compare(map.gesture.isPinchActive, false)
            map.gesture.enabled = true
            // 12. check nuthin happens if no active gestures
            clear_data()
            map.gesture.activeGestures = MapGestureArea.NoGesture
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),
                                 Qt.point(50,50), Qt.point(100,50),
                                 40, 40, 10, 10);
            tryCompare(pinchStartedSpy, "count", 0);
            wait(300);
            compare(pinchUpdatedSpy.count, 0);
            compare(pinchStartedSpy.count, 0);
            compare(map.zoomLevel, 8.5)
            pinchGenerator.stop()
            map.gesture.activeGestures = MapGestureArea.ZoomGesture
            // 13. manually changing zoom level during active pinch zoom
            clear_data();
            map.gesture.maximumZoomLevelChange = 2
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),
                                 Qt.point(50,50), Qt.point(100,50),
                                 40, 40, 10, 10);
            tryCompare(pinchStartedSpy, "count", 1);
            tryCompare(pinchActiveSpy, "count", 1)
            compare(map.gesture.isPinchActive, true)
            map.zoomLevel = 3 // will get overridden by pinch
            tryCompare(pinchFinishedSpy, "count", 1);
            verify(pinchUpdatedSpy.count >= 5); // verify 'sane' number of updates received
            compare(map.zoomLevel, 9.5)
            // 14. try to zoom below and above plugin's support
            clear_data()
            map.gesture.maximumZoomLevelChange = 4
            map.zoomLevel = map.minimumZoomLevel + 0.5
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),
                                 Qt.point(100,50),Qt.point(50,50),
                                 40, 40, 10, 10);
            tryCompare(pinchFinishedSpy, "count", 1);
            compare(map.zoomLevel, map.minimumZoomLevel)
            map.zoomLevel = map.maximumZoomLevel - 0.5
            pinchGenerator.pinch(Qt.point(50,50), Qt.point(0,50),Qt.point(50,50), Qt.point(100,50));
            tryCompare(pinchFinishedSpy, "count", 2);
            compare(map.zoomLevel, map.maximumZoomLevel)
            map.zoomLevel = 10
            // 15. check that pinch accepted works (rejection)
            clear_data()
            map.rejectPinch = true
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),
                                 Qt.point(100,50),Qt.point(50,50),
                                 40, 40, 10, 10);
            wait(300)
            compare(pinchUpdatedSpy.count, 0)
            compare(pinchFinishedSpy.count, 0)
            compare(map.gesture.isPinchActive, false)
            compare(map.zoomLevel, 10)
            map.rejectPinch = false
            pinchGenerator.stop()
            pinchGenerator.pinch(Qt.point(0,50),Qt.point(50,50),Qt.point(100,50),Qt.point(50,50));
            tryCompare(pinchFinishedSpy, "count",  1)
            compare(map.zoomLevel, 8)
            compare(map.lastPinchEvent.accepted, true)
            // 16. moving center
            clear_data()
            pinchGenerator.pinch(Qt.point(0, 50), Qt.point(50,100), Qt.point(50,0), Qt.point(100, 50))
            tryCompare(pinchStartedSpy.count, 1)
            compare(map.lastPinchEvent.center.x, (map.lastPinchEvent.point1.x + map.lastPinchEvent.point2.x) /2)
            compare(map.lastPinchEvent.center.x, (map.lastPinchEvent.point1.y + map.lastPinchEvent.point2.y) /2)
            tryCompare(pinchFinishedSpy, "count", 1)
            compare(map.lastPinchEvent.center.x, (map.lastPinchEvent.point1.x + map.lastPinchEvent.point2.x) /2)
            compare(map.lastPinchEvent.center.x, (map.lastPinchEvent.point1.y + map.lastPinchEvent.point2.y) /2)
            // sanity check that we are not comparing wrong (points) with wrong (center) and calling it a success
            verify((map.lastPinchEvent.center.x > 50) && (map.lastPinchEvent.center.x < 100))
            verify((map.lastPinchEvent.center.y > 50) && (map.lastPinchEvent.center.y < 100))
            // 17. angle between points
            clear_data()
            // todo calculate the angle from points for comparison
            pinchGenerator.pinch(Qt.point(0,0), Qt.point(0,100), Qt.point(100,100), Qt.point(100,0))
            tryCompare(pinchStartedSpy, "count", 1)
            verify(map.lastPinchEvent.angle >= -45 && map.lastPinchEvent.angle < -20)
            tryCompare(pinchFinishedSpy, "count", 1)
            verify(map.lastPinchEvent.angle >= 20 && map.lastPinchEvent.angle <= 45)
        }
    }
}
