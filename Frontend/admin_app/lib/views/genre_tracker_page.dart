import 'package:admin_app/models/DTOs/similarity_matrix_dto.dart';
import 'package:admin_app/models/genre.dart';
import 'package:admin_app/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GenreTracker extends StatefulWidget {
  GenreTracker({super.key});

  @override
  State<GenreTracker> createState() => _GenreTrackerState();
}

class _GenreTrackerState extends State<GenreTracker> {
  late Future<SimilarityMatrixDto> similarityMatrix;

  @override
  void initState() {
    super.initState();
    similarityMatrix = fetchSimilarityMatrix();
  }

  Future<SimilarityMatrixDto> fetchSimilarityMatrix() async {
    return GetIt.I<AdminService>().GetSimilarityMatrix();
  }

  void updateSimilarityMatrix() {
    setState(() {
      similarityMatrix = GetIt.I<AdminService>().UpdateSimilarityMatrix();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 25, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Genre similarity scores matrix",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    ElevatedButton.icon(
                      onPressed: updateSimilarityMatrix,
                      icon: Icon(Icons.update),
                      label: Text("Recreate and update matrix"),
                    ),
                  ],
                )),
            Expanded(
              child: FutureBuilder<SimilarityMatrixDto>(
                future: similarityMatrix,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return _buildDataGrid(snapshot.data!);
                  }
                  return SizedBox.shrink(); // Fallback for unexpected state
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildDataGrid(SimilarityMatrixDto data) {
  return SfDataGrid(
    source: _getDataSource(data),
    columns: _buildColumns(data),
    frozenColumnsCount: 1,
    selectionMode: SelectionMode.single,
  );
}


List<GridColumn> _buildColumns(SimilarityMatrixDto data) {
  return [
        GridColumn(
          columnName: 'Genre',
          width: 130,
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(
              'Genre'.substring(0, 1).toUpperCase() + 'Genre'.substring(1),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ] +
      data.genres.map((genre) {
        return GridColumn(
          width: 130,
          columnName: genre.name,
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(
              genre.name.substring(0, 1).toUpperCase() + genre.name.substring(1),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList();
}


  DataGridSource _getDataSource(SimilarityMatrixDto data) {
    return _GenreDataSource(data);
  }
}

class _GenreDataSource extends DataGridSource {
  _GenreDataSource(this.data);

  final SimilarityMatrixDto data;

  @override
  List<DataGridRow> get rows => _getRows();

  List<DataGridRow> _getRows() {
    return data.genres.map((genre) {
      return DataGridRow(cells: _getCells(genre));
    }).toList();
  }

  List<DataGridCell> _getCells(Genre genre) {
    var genreIndex = data.genres.indexWhere((element) => element.id == genre.id);
    return [
          DataGridCell<String>(columnName: genre.name, value: genre.name.substring(0, 1).toUpperCase() + genre.name.substring(1)),
        ] +
        data.genres
            .asMap()
            .entries
            .map((entry) {
              int index = entry.key;
              if (index == genreIndex) {
                return DataGridCell<String>(
                  columnName: genre.name,
                  value: 'x',
                );
              }
              var result = DataGridCell<String>(
                columnName: genre.name,
                value: data.similarityScores[index][genreIndex].toStringAsFixed(2),
              );

              return result;
            })
            .toList()
            .toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow dataGridRow) {
    return DataGridRowAdapter(
      cells: dataGridRow.getCells().map((DataGridCell cell) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
}
