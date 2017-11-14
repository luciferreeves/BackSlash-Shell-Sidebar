import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.notifications 1.0

Item {
    id: jobsRoot
    property alias count: jobs.count

    property ListModel model: ListModel {
        id: jobs
    }

    property QtObject jobsSource : PlasmaCore.DataSource {
        id: jobsSource

        property var runningJobs: ({})

        engine: "applicationjobs"
        interval: 0

        onSourceAdded: {
            connectSource(source)
            jobs.append({name: source})
        }

        onSourceRemoved: {
            // remove source from jobs model
            for (var i = 0, len = jobs.count; i < len; ++i) {
                if (jobs.get(i).name === source) {
                    jobs.remove(i)
                    break
                }
            }

            if (!notifications) {
                return
            }

            var error = runningJobs[source]["error"]
            var errorText = runningJobs[source]["errorText"]

            // 1 = ERR_USER_CANCELED - don't show any notification at all
            if (error == 1) {
                return
            }

            var message = runningJobs[source]["label1"] ? runningJobs[source]["label1"] : runningJobs[source]["label0"]
            var infoMessage = runningJobs[source]["infoMessage"]
            if (!message && !infoMessage) {
                return
            }

            var summary = infoMessage ? i18nc("the job, which can be anything, has finished", "%1: Finished", infoMessage) : i18n("Job Finished")

            if (error) {
                summary = infoMessage ? i18nc("the job, which can be anything, failed to complete", "%1: Failed", infoMessage) : i18n("Job Failed")
            }

            var op = {
                appIcon: runningJobs[source].appIconName,
                appName: runningJobs[source].appName,
                summary: summary,
                body: errorText || message,
                isPersistent: true,
                expireTimeout: 6000,
                urgency: 0,
                configurable: false,
                actions: !error && UrlHelper.isUrlValid(message) ? ["jobUrl#" + message, i18n("Open...")] : []
            }; // If the actionId contains "jobUrl#", it tries to open the "id" value (which is "message")

            notifications.createNotification(op);

            delete runningJobs[source]
        }

        onNewData: {
            runningJobs[sourceName] = data
        }

        onDataChanged: {
            var total = 0
            for (var i = 0; i < sources.length; ++i) {
                if (jobsSource.data[sources[i]] && jobsSource.data[sources[i]]["percentage"]) {
                    total += jobsSource.data[sources[i]]["percentage"]
                }
            }

            total /= sources.length
            notificationsApplet.globalProgress = total/100
        }

        Component.onCompleted: {
            connectedSources = sources
        }
    }
}
