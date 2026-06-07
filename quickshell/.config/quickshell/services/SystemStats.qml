import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: systemStats

    property int cpuUsage: 0
    property int memUsage: 0
    property int volumeLevel: 0

    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                const parts = data.trim().split(/\s+/)
                const user = parseInt(parts[1]) || 0
                const nice = parseInt(parts[2]) || 0
                const system = parseInt(parts[3]) || 0
                const idle = parseInt(parts[4]) || 0
                const iowait = parseInt(parts[5]) || 0
                const irq = parseInt(parts[6]) || 0
                const softirq = parseInt(parts[7]) || 0

                const total = user + nice + system + idle + iowait + irq + softirq
                const idleTime = idle + iowait

                if (systemStats.lastCpuTotal > 0) {
                    const totalDiff = total - systemStats.lastCpuTotal
                    const idleDiff = idleTime - systemStats.lastCpuIdle
                    if (totalDiff > 0) {
                        systemStats.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                    }
                }

                systemStats.lastCpuTotal = total
                systemStats.lastCpuIdle = idleTime
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                const parts = data.trim().split(/\s+/)
                const total = parseInt(parts[1]) || 1
                const used = parseInt(parts[2]) || 0
                systemStats.memUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return

                const match = data.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    systemStats.volumeLevel = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            volProc.running = true
        }
    }
}
