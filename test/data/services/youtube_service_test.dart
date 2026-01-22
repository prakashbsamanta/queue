import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flow_state/data/services/youtube_service.dart';

@GenerateNiceMocks([
  MockSpec<YoutubeExplode>(),
  MockSpec<VideoClient>(),
  MockSpec<PlaylistClient>(),
  MockSpec<Video>(),
  MockSpec<Playlist>(),
  MockSpec<Channel>(),
])
import 'youtube_service_test.mocks.dart';

void main() {
  late MockYoutubeExplode mockYoutubeExplode;
  late MockVideoClient mockVideoClient;
  late MockPlaylistClient mockPlaylistClient;
  late YouTubeService service;

  setUp(() {
    mockYoutubeExplode = MockYoutubeExplode();
    mockVideoClient = MockVideoClient();
    mockPlaylistClient = MockPlaylistClient();

    when(mockYoutubeExplode.videos).thenReturn(mockVideoClient);
    when(mockYoutubeExplode.playlists).thenReturn(mockPlaylistClient);
    
    // Service uses the injected client but we must ensure it doesn't close it if we want to reuse?
    // Actually the mock will be closed by the service finally block.
    service = YouTubeService(mockYoutubeExplode);
  });

  test('extractCourse from Single Video URL returns valid Course', () async {
    const videoUrl = 'https://www.youtube.com/watch?v=AaBbCcDdEeF';
    final videoId = VideoId('AaBbCcDdEeF');
    
    final mockVideo = MockVideo();
    when(mockVideo.id).thenReturn(videoId);
    when(mockVideo.title).thenReturn('Test Video');
    when(mockVideo.duration).thenReturn(const Duration(seconds: 100));
    when(mockVideo.thumbnails).thenReturn(ThumbnailSet('id')); 

    when(mockVideoClient.get(any)).thenAnswer((_) async => mockVideo);

    final course = await service.extractCourse(videoUrl);

    expect(course.title, 'Test Video');
    expect(course.videos.length, 1);
    expect(course.totalDuration, 100);
    verify(mockVideoClient.get(any)).called(1);
    verify(mockYoutubeExplode.close()).called(1);
  });
  
  test('extractCourse from Playlist URL returns valid Course', () async {
    const playlistUrl = 'https://www.youtube.com/playlist?list=PLAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPp';
    
    final mockPlaylist = MockPlaylist();
    when(mockPlaylist.title).thenReturn('Test Playlist');
    
    final mockVideo = MockVideo();
    when(mockVideo.id).thenReturn(VideoId('AaBbCcDdEeF'));
    when(mockVideo.title).thenReturn('V1');
    when(mockVideo.duration).thenReturn(const Duration(seconds: 50));
    when(mockVideo.thumbnails).thenReturn(ThumbnailSet('v1'));

    when(mockPlaylistClient.get(any)).thenAnswer((_) async => mockPlaylist);
    when(mockPlaylistClient.getVideos(any)).thenAnswer((_) => Stream.value(mockVideo));

    final course = await service.extractCourse(playlistUrl);

    expect(course.title, 'Test Playlist');
    expect(course.videos.length, 1);
    expect(course.totalDuration, 50);
    verify(mockPlaylistClient.get(any)).called(1);
    verify(mockYoutubeExplode.close()).called(1);
  });

  test('extractCourse returns error on Exception', () async {
     when(mockVideoClient.get(any)).thenThrow(Exception('Network Error'));
     
     expect(
       () => service.extractCourse('https://www.youtube.com/watch?v=AaBbCcDdEeF'),
       throwsA(isA<Exception>())
     );
     
     // Allow verifying close even if other calls happened
     // verify(mockYoutubeExplode.close()).called(1);
  });
}
