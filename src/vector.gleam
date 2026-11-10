import gleam/float

pub type Vector {
  Vector(x: Float, y: Float)
}

pub fn perpendicular(v: Vector) -> Vector {
  Vector(x: 0.0 -. v.y, y: v.x)
}

pub fn length(v: Vector) -> Float {
  let squared = v.x *. v.x +. v.y *. v.y
  case squared |> float.square_root {
    Ok(result) -> result
    Error(Nil) -> 0.0
  }
}

pub fn normalize(v: Vector) -> Vector {
  let len = length(v)
  Vector(x: v.x /. len, y: v.y /. len)
}

pub fn scale_vector(v: Vector, s: Float) -> Vector {
  Vector(x: v.x *. s, y: v.y *. s)
}

pub fn add_vectors(a: Vector, b: Vector) {
  Vector(x: a.x +. b.x, y: a.y +. b.y)
}

pub fn subtract_vectors(a: Vector, b: Vector) {
  add_vectors(a, scale_vector(b, -1.0))
}
