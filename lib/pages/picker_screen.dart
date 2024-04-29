import 'package:ascend_fyp/getters/user_media.dart';
import 'package:ascend_fyp/models/media.dart';
import 'package:ascend_fyp/widgets/media_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PickerScreen extends StatefulWidget {
  final List<Media> selectedMedia;
  const PickerScreen({
    super.key,
    required this.selectedMedia,
  });

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final List<Media> _selectedMedias = [];
  AssetPathEntity? _currentAlbum;
  List<AssetPathEntity> _albums = [];

  void _loadAlbums() async {
    List<AssetPathEntity> albums = await fetchAlbums();

    if (albums.isNotEmpty) {
      setState(() {
        _currentAlbum = albums.first;
        _albums = albums;
      });

      _loadMedias();
    }
  }

  final List<Media> _medias = [];
  int _lastPage = 0;
  int _currentPage = 0;

  void _loadMedias() async {
    _lastPage = _currentPage;
    if (_currentAlbum != null) {
      List<Media> medias =
          await fetchMedias(album: _currentAlbum!, page: _currentPage);
      setState(() {
        _medias.addAll(medias);
      });
    }
  }

  @override
  void initState() {
    _selectedMedias.addAll(widget.selectedMedia);
    _loadAlbums();
    super.initState();
    _scrollController.addListener(_loadMoreMedias);
  }

  final ScrollController _scrollController = ScrollController();

  void _loadMoreMedias() {
    if (_scrollController.position.pixels /
            _scrollController.position.maxScrollExtent >
        0.33) {
      if (_currentPage != _lastPage) {
        _loadMedias();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreMedias);
    _scrollController.dispose();
    super.dispose();
  }

  void _selectMedia(Media media) {
    bool isSelected = _selectedMedias
        .any((element) => element.assetEntity.id == media.assetEntity.id);

    setState(() {
      if (isSelected) {
        _selectedMedias.removeWhere(
            (element) => element.assetEntity.id == media.assetEntity.id);
      } else {
        _selectedMedias.add(media);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color.fromRGBO(247, 243, 237, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: DropdownButton<AssetPathEntity>(
          borderRadius: BorderRadius.circular(16),
          value: _currentAlbum,
          items: _albums
              .map((e) => DropdownMenuItem<AssetPathEntity>(
                    child: Text(e.name.isEmpty ? "0" : e.name),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _currentAlbum = value;
              _currentPage = 0;
              _lastPage = 0;
              _medias.clear();
            });
            _loadMedias();
            _scrollController.jumpTo(0.0);
          },
        ),
      ),
      body: MediaGridView(
        medias: _medias,
        selectedMedias: _selectedMedias,
        selectMedia: _selectMedia,
        scrollController: _scrollController,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context, _selectedMedias),
        child: const Icon(Icons.check_rounded),
      ),
    );
  }
}
