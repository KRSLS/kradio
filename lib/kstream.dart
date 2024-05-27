class KStream {
  int? index;
  String title;
  String url;
  String urlNext;
  String? description;
  String? urlImage;
  String? customUrlImage;
  bool isFavorite;

  KStream({
    this.index,
    required this.title,
    required this.url,
    required this.urlNext,
    this.description,
    this.urlImage,
    this.customUrlImage,
    required this.isFavorite,
  });

  static List<KStream> streams = [
    KStream(
      index: 0,
      title: 'KISS 60s',
      url: 'https://netradio.live24.gr/kiss-web-classic',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/60s/AirPlayNext.xml',
      urlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExODc1c3FqdGRlMjQyYXgwYXJrYWpzdjZpdzYxOWZudHE1d3NoM3VmZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjgWQA5QBuBmUZahOP/giphy.gif',
      customUrlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExODc1c3FqdGRlMjQyYXgwYXJrYWpzdjZpdzYxOWZudHE1d3NoM3VmZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjgWQA5QBuBmUZahOP/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 1,
      title: 'KISS 70s',
      url: 'https://netradio.live24.gr/kiss-web-70s',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/70s/AirPlayNext.xml',
      urlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExODc1c3FqdGRlMjQyYXgwYXJrYWpzdjZpdzYxOWZudHE1d3NoM3VmZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjgWQA5QBuBmUZahOP/giphy.gif',
      customUrlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExODc1c3FqdGRlMjQyYXgwYXJrYWpzdjZpdzYxOWZudHE1d3NoM3VmZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/gjgWQA5QBuBmUZahOP/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 2,
      title: 'KISS 80s',
      url: 'https://netradio.live24.gr/kiss-web-80s',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/80s/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 3,
      title: 'KISS 90s',
      url: 'https://netradio.live24.gr/kiss-web-90s',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/90s/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 4,
      title: 'KISS 00s',
      url: 'https://netradio.live24.gr/kiss-web-oos',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/00s/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 5,
      title: 'KISS DISCO',
      url: 'https://netradio.live24.gr/actionfm',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Disco/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 6,
      title: 'KISS LATIN',
      url: 'https://netradio.live24.gr/kiss-web-latin1',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Latin/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 7,
      title: 'KISS CHILL',
      url: 'https://netradio.live24.gr/kiss-web-lounge',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Chill/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 8,
      title: 'KISS BALLADS',
      url: 'https://netradio.live24.gr/kiss-web-balads',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Ballads/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 9,
      title: 'KISS XMAS',
      url: 'https://netradio.live24.gr/kiss-web-xmas',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/KissMas/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 10,
      title: 'KISS JAZZ',
      url: 'https://netradio.live24.gr/kiss-web-jazz',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Jazz/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 11,
      title: 'REBEL',
      url: 'https://netradio.live24.gr/rebel1052',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Rebel/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 12,
      title: 'NRG',
      url: 'https://netradio.live24.gr/kiss-web-nrg',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/NRG/AirPlayNext.xml',
      urlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      customUrlImage:
          'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNWdrdXNsYWFhbzV2YjlwNzl0ZXVjdHE3YTliNGt1YnV3YjVmMTh6cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/tHIRLHtNwxpjIFqPdV/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 13,
      title: 'CAVIAR',
      description: 'OOOOOOHhhhh babyyyy',
      url: 'https://netradio.live24.gr/kiss-web-rock',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/Caviar/AirPlayNext.xml',
      urlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExdnUyZWR0Z3hxaDNtYnkxeHBobjBqb2dkbXJqMTliaW1ybnp5NG82NCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/kOLg4qXvFpGrC/giphy.gif',
      customUrlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExdnUyZWR0Z3hxaDNtYnkxeHBobjBqb2dkbXJqMTliaW1ybnp5NG82NCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/kOLg4qXvFpGrC/giphy.gif',
      isFavorite: false,
    ),
    KStream(
      index: 14,
      title: 'HOT',
      description: 'Amazing, dev loves this.',
      url: 'https://netradio.live24.gr/hotfm',
      urlNext:
          'https://deliver.siliconweb.com/kissfm/Webradios/HotFM/AirPlayNext.xml',
      urlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExYmF3eGwxaHg0MmJscHdpbXFwd3kycXQyZm9kMXVocDE2ODlpcTN5YSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3oEduW9Vw1C4tYG7te/giphy.gif',
      customUrlImage:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExYmF3eGwxaHg0MmJscHdpbXFwd3kycXQyZm9kMXVocDE2ODlpcTN5YSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3oEduW9Vw1C4tYG7te/giphy.gif',
      isFavorite: false,
    ),
  ];
}
