import 'package:flutter/material.dart';

/// Tabla con desplazamiento horizontal para pantallas pequeñas.
///
/// La primera columna se considera texto; las demás se alinean a la derecha
/// porque suelen contener números.
class ScrollableTable extends StatelessWidget {
  const ScrollableTable({
    super.key,
    required this.columns,
    required this.rows,
    this.highlightedRows = const {},
    this.rowColors = const {},
    this.caption,
  });

  final List<String> columns;
  final List<List<String>> rows;

  /// Índices de filas que se muestran resaltadas.
  final Set<int> highlightedRows;

  /// Color de texto opcional por índice de fila.
  final Map<int, Color> rowColors;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = caption;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.primaryContainer,
              ),
              headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              columnSpacing: 20,
              horizontalMargin: 12,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 44,
              columns: [
                for (var i = 0; i < columns.length; i++)
                  DataColumn(label: Text(columns[i]), numeric: i > 0),
              ],
              rows: [
                for (var r = 0; r < rows.length; r++)
                  DataRow(
                    color: highlightedRows.contains(r)
                        ? WidgetStatePropertyAll(
                            theme.colorScheme.secondaryContainer,
                          )
                        : null,
                    cells: [
                      for (var c = 0; c < columns.length; c++)
                        DataCell(
                          Text(
                            c < rows[r].length ? rows[r][c] : '',
                            style: TextStyle(
                              color: rowColors[r],
                              fontWeight: highlightedRows.contains(r)
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Text(note, style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
