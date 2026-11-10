import gleam/float
import gleam/list
import vector.{type Vector, Vector}

pub type Point {
  Point(x: Float, y: Float)
}

pub type Apex {
  Apex(x: Float, y: Float, h: Float)
}

pub type Pyramid {
  Pyramid(base: List(Point), apex: Apex)
}

fn slant_length(point: Point, apex: Apex) -> Float {
  let dx = point.x -. apex.x
  let dy = point.y -. apex.y
  let h = apex.h

  let root = float.square_root(square(dx) +. square(dy) +. square(h))
  case root {
    Ok(result) -> result
    Error(Nil) -> 0.0
  }
}

fn points_to_vector(a: Point, b: Point) -> Vector {
  Vector(x: b.x -. a.x, y: b.y -. a.y)
}

fn square(a: Float) -> Float {
  a *. a
}

pub fn unfold_apex(apex: Apex, a: Point, b: Point) -> #(Point, Point) {
  let base_vec = points_to_vector(a, b)
  let base_len = vector.length(base_vec)
  let base_unit_vec = vector.normalize(base_vec)
  let perp_unit_vec = vector.perpendicular(base_unit_vec)

  let slant_len_a = slant_length(a, apex)
  let slant_len_b = slant_length(b, apex)

  let edge_distance = {
    let nominator =
      square(slant_len_a) -. square(slant_len_b) +. square(base_len)
    let denominator = 2.0 *. base_len
    nominator /. denominator
  }

  let perpendicular_distance = {
    case square(slant_len_a) -. square(edge_distance) |> float.square_root {
      Ok(result) -> result
      Error(Nil) -> 0.0
    }
  }

  let projected_1 =
    Point(
      x: a.x
        +. edge_distance
        *. base_unit_vec.x
        +. perpendicular_distance
        *. perp_unit_vec.x,
      y: a.y
        +. edge_distance
        *. base_unit_vec.y
        -. perpendicular_distance
        *. perp_unit_vec.y,
    )

  let projected_2 =
    Point(
      x: a.x
        +. edge_distance
        *. base_unit_vec.x
        +. perpendicular_distance
        *. perp_unit_vec.x,
      y: a.y
        +. edge_distance
        *. base_unit_vec.y
        +. perpendicular_distance
        *. perp_unit_vec.y,
    )

  #(projected_1, projected_2)
}

pub fn unfold_pyramid(pyramid: Pyramid) -> List(#(Point, Point)) {
  case pyramid.base |> list.last {
    Ok(last) -> {
      [last, ..pyramid.base]
      |> list.window_by_2
      |> list.map(fn(edge) { unfold_apex(pyramid.apex, edge.0, edge.1) })
    }
    Error(Nil) -> []
  }
}
