/// 상품 모델
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String subCategory;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = '',
    this.subCategory = '',
  });

  /// 샘플 상품 데이터
  static List<Product> sampleProducts = [
    Product(
      id: 'ITEM_001',
      name: '프리미엄 무선 마우스',
      description: '인체공학적 디자인의 고급 무선 마우스입니다. 정밀한 트래킹과 편안한 그립감을 제공합니다.',
      price: 45000,
      imageUrl: 'https://via.placeholder.com/200x200/4A90D9/FFFFFF?text=Mouse',
      category: '컴퓨터',
      subCategory: '주변기기',
    ),
    Product(
      id: 'ITEM_002',
      name: '기계식 게이밍 키보드',
      description: '청축 스위치가 장착된 풀배열 기계식 키보드입니다. RGB 백라이트 지원.',
      price: 89000,
      imageUrl: 'https://via.placeholder.com/200x200/50C878/FFFFFF?text=Keyboard',
      category: '컴퓨터',
      subCategory: '주변기기',
    ),
    Product(
      id: 'ITEM_003',
      name: '27인치 QHD 모니터',
      description: '선명한 화질의 27인치 QHD 모니터입니다. 144Hz 주사율로 부드러운 화면.',
      price: 350000,
      imageUrl: 'https://via.placeholder.com/200x200/FF6B6B/FFFFFF?text=Monitor',
      category: '컴퓨터',
      subCategory: '모니터',
    ),
    Product(
      id: 'ITEM_004',
      name: 'USB-C 허브 (7포트)',
      description: 'HDMI, USB 3.0, SD카드 리더기가 포함된 올인원 USB-C 허브.',
      price: 65000,
      imageUrl: 'https://via.placeholder.com/200x200/9B59B6/FFFFFF?text=Hub',
      category: '컴퓨터',
      subCategory: '주변기기',
    ),
    Product(
      id: 'ITEM_005',
      name: '무선 이어폰 Pro',
      description: '노이즈 캔슬링 기능이 탑재된 프리미엄 무선 이어폰. 최대 24시간 재생.',
      price: 199000,
      imageUrl: 'https://via.placeholder.com/200x200/F39C12/FFFFFF?text=Earbuds',
      category: '음향기기',
      subCategory: '이어폰',
    ),
    Product(
      id: 'ITEM_006',
      name: '스마트 워치 SE',
      description: '심박수, 수면 분석, 운동 추적 기능이 포함된 스마트 워치.',
      price: 279000,
      imageUrl: 'https://via.placeholder.com/200x200/1ABC9C/FFFFFF?text=Watch',
      category: '웨어러블',
      subCategory: '스마트워치',
    ),
  ];
}
