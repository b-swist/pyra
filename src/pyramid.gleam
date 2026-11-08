pub type Point {
  Point(x: Float, y: Float)
}

pub type Apex {
  Apex(x: Float, y: Float, h: Float)
}

pub type Pyramid {
  Pyramid(base: List(Point), apex: Apex)
}
