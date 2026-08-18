class Fruit {
  final String id;
  final String name;
  final String imageUrl;

  const Fruit({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

const List<Fruit> kFruits = [
  Fruit(
    id: 'apple',
    name: 'Apple',
    imageUrl: 'https://plus.unsplash.com/premium_photo-1724249990837-f6dfcb7f3eaa?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ),
  Fruit(
    id: 'pear',
    name: 'Pear',
    imageUrl: 'https://plus.unsplash.com/premium_photo-1672976699507-521b6bb1f0cb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cGVhcnxlbnwwfHwwfHx8MA%3D%3D',
  ),
  Fruit(
    id: 'dragonfruit',
    name: 'Dragon Fruit',
    imageUrl: 'https://plus.unsplash.com/premium_photo-1671379041175-782d15092945?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZHJhZ29uJTIwZnJ1aXR8ZW58MHx8MHx8fDA%3D',
  ),
  Fruit(
    id: 'avocado',
    name: 'Avocado',
    imageUrl: 'https://plus.unsplash.com/premium_photo-1724250043016-81ae56238026?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8YXZvY2Fkb3xlbnwwfHwwfHx8MA%3D%3D',
  ),
  Fruit(
    id: 'papaya',
    name: 'Papaya',
    imageUrl: 'https://plus.unsplash.com/premium_photo-1722938907181-08d806f7b9a6?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cGFwYXlhfGVufDB8fDB8fHww',
  ),
  Fruit(
    id: 'cherry',
    name: 'Cherries',
    imageUrl: 'https://images.unsplash.com/photo-1528821154947-1aa3d1b74941?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y2hlcnJ5fGVufDB8fDB8fHww',
  ),
];