import QtQuick 2.9
import QtCharts 2.1
import QtQuick.Controls 1.4
import Cadence.Prototyping.Extensions  1.0

ChartView {
    id: root

    function resetChart(s) {
        visible = s.chartVisible(); // qml will also decide if this is visible
        if (!s.chartVisible())
            return;
        removeAllSeries();
        title = s.title()
        var s1 = createSeries(ChartView.SeriesTypeBar, "yyy", barCategoriesAxis, valueAxisY)
        s.setBarSeries(0, s1)
        s.setCategoryAxis(0, barCategoriesAxis)
        s.setYAxis(0, valueAxisY)
        s.setYAxisRight(0, valueAxisYRight)
        // Add more series in the future

        root.width = Math.max(barCategoriesAxis.count * 40, 600)
        root.height = Math.min(0.75 * root.widt, 500)
    }

    ValueAxis{
        id: valueAxisY
        min: 0.0
        max: 1.0
    }

    ValueAxis{
        id: valueAxisYRight
        min: 0.0
        max: 1.0
    }

    BarCategoryAxis {
       id: barCategoriesAxis
    }

    ValueAxis {
        id: valueAxisX
        // Hide the value axis; it is only used to map the line series to bar categories axis
        visible: false
        min: 0.0
        max: 5.0
    }

    width: 600
    height: 400
    theme: ChartView.ChartThemeBlueIcy
    legend.alignment: Qt.AlignBottom
    antialiasing: true
}




