pragma Singleton

import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: service

    property string preferredPlayerDbusName: ""
    property string lastActivePlayerDbusName: ""
    property int selectionRevision: 0

    readonly property bool available: true
    readonly property var players: Mpris.players.values
    readonly property int playerCount: players.length
    readonly property var activePlayer: resolveActivePlayer()
    readonly property bool hasPlayers: activePlayer !== null
    readonly property string activePlayerName: activePlayer ? activePlayer.dbusName : ""
    readonly property string playerName: {
        if (!activePlayer)
            return ""

        const prefix = "org.mpris.MediaPlayer2."
        return activePlayer.dbusName.startsWith(prefix)
            ? activePlayer.dbusName.slice(prefix.length)
            : activePlayer.dbusName
    }
    readonly property string identity: activePlayer ? activePlayer.identity : ""
    readonly property string playbackStatus: playbackStateLabel(activePlayer)
    readonly property string title: activePlayer ? activePlayer.trackTitle : ""
    readonly property string artist: activePlayer ? activePlayer.trackArtist : ""
    readonly property string album: activePlayer ? activePlayer.trackAlbum : ""
    readonly property string artUrl: activePlayer ? activePlayer.trackArtUrl : ""
    readonly property string desktopEntry: activePlayer ? activePlayer.desktopEntry : ""
    readonly property bool canGoPrevious: activePlayer ? activePlayer.canGoPrevious : false
    readonly property bool canTogglePlayback: activePlayer ? activePlayer.canTogglePlaying : false
    readonly property bool canGoNext: activePlayer ? activePlayer.canGoNext : false
    readonly property bool canRaise: activePlayer ? activePlayer.canRaise : false

    readonly property string displayTitle: title || (hasPlayers ? "Unknown track" : "Nothing playing")
    readonly property string displaySubtitle: {
        if (artist)
            return artist
        if (album)
            return album
        if (identity)
            return identity
        return hasPlayers ? playerName : "No active MPRIS players"
    }

    function playbackStateLabel(player) {
        if (!player)
            return "Stopped"

        if (player.playbackState === MprisPlaybackState.Playing)
            return "Playing"

        if (player.playbackState === MprisPlaybackState.Paused)
            return "Paused"

        return "Stopped"
    }

    function playerByDbusName(dbusName) {
        for (const player of players) {
            if (player.dbusName === dbusName)
                return player
        }

        return null
    }

    function firstPlayingPlayer() {
        for (const player of players) {
            if (player.isPlaying)
                return player
        }

        return null
    }

    function normalizeTrackedPlayers() {
        if (preferredPlayerDbusName && !playerByDbusName(preferredPlayerDbusName))
            preferredPlayerDbusName = ""

        if (lastActivePlayerDbusName && !playerByDbusName(lastActivePlayerDbusName))
            lastActivePlayerDbusName = ""

        if (!lastActivePlayerDbusName && players.length > 0)
            lastActivePlayerDbusName = players[0].dbusName
    }

    function bumpSelection() {
        normalizeTrackedPlayers()
        selectionRevision++
    }

    function resolveActivePlayer() {
        const _revision = selectionRevision

        if (players.length === 0)
            return null

        if (preferredPlayerDbusName) {
            const preferred = playerByDbusName(preferredPlayerDbusName)
            if (preferred)
                return preferred
        }

        const lastPlaying = playerByDbusName(lastActivePlayerDbusName)
        if (lastPlaying && lastPlaying.isPlaying)
            return lastPlaying

        const currentlyPlaying = firstPlayingPlayer()
        if (currentlyPlaying)
            return currentlyPlaying

        const lastActive = playerByDbusName(lastActivePlayerDbusName)
        if (lastActive)
            return lastActive

        return players[0]
    }

    function notePlayerActivity(player) {
        if (!player)
            return

        lastActivePlayerDbusName = player.dbusName

        if (preferredPlayerDbusName && !playerByDbusName(preferredPlayerDbusName))
            preferredPlayerDbusName = ""

        selectionRevision++
    }

    function selectPlayer(player) {
        const dbusName = typeof player === "string"
            ? player
            : (player ? player.dbusName : "")

        if (!dbusName)
            return

        preferredPlayerDbusName = dbusName
        lastActivePlayerDbusName = dbusName
        selectionRevision++
    }

    function clearPreferredPlayer() {
        preferredPlayerDbusName = ""
        selectionRevision++
    }

    function togglePlayback() {
        if (activePlayer && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying()
    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious)
            activePlayer.previous()
    }

    function next() {
        if (activePlayer && activePlayer.canGoNext)
            activePlayer.next()
    }

    function raise() {
        if (activePlayer && activePlayer.canRaise)
            activePlayer.raise()
    }

    property Connections playersModelConnections: Connections {
        target: Mpris.players

        function onObjectInsertedPost() {
            service.bumpSelection()
        }

        function onObjectRemovedPost() {
            service.bumpSelection()
        }
    }

    property Instantiator playerWatchers: Instantiator {
        model: Mpris.players

        delegate: Connections {
            required property var modelData

            target: modelData
            ignoreUnknownSignals: true

            function onTrackChanged() {
                service.notePlayerActivity(modelData)
            }

            function onPostTrackChanged() {
                service.notePlayerActivity(modelData)
            }

            function onIsPlayingChanged() {
                if (modelData.isPlaying || service.lastActivePlayerDbusName === modelData.dbusName) {
                    service.notePlayerActivity(modelData)
                } else {
                    service.bumpSelection()
                }
            }

            function onPlaybackStateChanged() {
                if (modelData.isPlaying || service.lastActivePlayerDbusName === modelData.dbusName) {
                    service.notePlayerActivity(modelData)
                } else {
                    service.bumpSelection()
                }
            }
        }
    }

    Component.onCompleted: {
        bumpSelection()
    }
}
