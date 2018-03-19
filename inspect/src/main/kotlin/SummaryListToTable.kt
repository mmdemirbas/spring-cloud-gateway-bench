import java.io.File


fun main(args: Array<String>) {
    val fillPaddingWithLastValue = true
    val input = File("./reports/summary-list.csv")
    val output = input.resolveSibling("summary-table.csv")

    val columns =
            input.readLines().map { line -> line.split(',') }.groupBy { row -> row[0] }
                .map { (title, rows) -> listOf(title) + rows.map { row -> row[1] } }

    val transformedRowCount = columns.map { column -> column.size }.max() ?: 0
    val transformedRows = (0 until transformedRowCount).map { rowIndex ->
        columns.map { column ->
            when {
                rowIndex < column.size   -> column[rowIndex]
                fillPaddingWithLastValue -> column[column.size - 1]
                else                     -> ""
            }
        }
    }

    val outputCsv = transformedRows.joinToString(separator = "\n") { rows -> rows.joinToString(separator = ",") }
    output.writeText(outputCsv)
}
