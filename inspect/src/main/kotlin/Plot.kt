import org.knowm.xchart.BitmapEncoder
import org.knowm.xchart.XChartPanel
import org.knowm.xchart.XYChart
import org.knowm.xchart.XYSeries.XYSeriesRenderStyle
import org.knowm.xchart.style.Styler.LegendPosition
import java.awt.BorderLayout
import java.io.File
import javax.swing.JFrame
import javax.swing.SwingUtilities

enum class OutputMode {
    SHOW, SAVE
}

fun main(args: Array<String>) {
    val outputMode = OutputMode.SAVE
    val input = File("./reports/summary-list.csv")

    val data =
            input.readLines().map { line -> line.split(',') }.groupBy { row -> row[0] }
                .mapValues { (_, rows) -> rows.map { row -> row[1].toDouble() } }

    val groups = data.keys.map { it.split('/')[0] }.distinct()

    groups.forEach { group ->
        // Build chart
        val chart = XYChart(600, 800).apply {
            this.title = group
            xAxisTitle = "Successive Runs"
            yAxisTitle = "Requests/Sec"
            styler.run {
                legendPosition = LegendPosition.InsideNE
                defaultSeriesRenderStyle = XYSeriesRenderStyle.Line
            }
            data.filter { (title, _) -> title.startsWith("$group/") }.forEach { (title, values) ->
                addSeries(title, (1..values.size).map { it + 0.0 }.toList().toDoubleArray(), values.toDoubleArray())
            }
        }

        when (outputMode) {
            OutputMode.SHOW -> SwingUtilities.invokeLater {
                JFrame("API Gateway Comparisons").apply {
                    layout = BorderLayout()
                    defaultCloseOperation = JFrame.EXIT_ON_CLOSE
                    add(XChartPanel(chart), BorderLayout.CENTER)
                    pack()
                    isVisible = true
                }
            }
            OutputMode.SAVE -> {
                val subdir = input.resolveSibling("charts")
                subdir.mkdirs()
                BitmapEncoder.saveBitmapWithDPI(chart,
                                                subdir.resolve(group).toString(),
                                                BitmapEncoder.BitmapFormat.PNG,
                                                54)
            }
        }
    }
}

