import formal/form.{type Form}
import gleam/list
import gleam/option.{type Option, None, Some}
import pyramid.{type Pyramid, Apex, Point, Pyramid}

pub type Model {
  Model(count: Int, state: Form(Pyramid), output: Option(Pyramid))
}

pub fn init(_) -> Model {
  new_model(3)
}

pub fn new_model(points: Int) {
  let defaults =
    list.flatten([
      [
        #("apex-x", ""),
        #("apex-y", ""),
        #("apex-h", ""),
      ],
      list.repeat([#("point-x", ""), #("point-y", "")], times: points)
        |> list.flatten,
    ])

  Model(
    count: points,
    state: new_form() |> form.set_values(defaults),
    output: None,
  )
}

fn new_form() -> Form(Pyramid) {
  form.new({
    use xs <- form.field("point-x", form.parse_list(form.parse_float))
    use ys <- form.field("point-y", form.parse_list(form.parse_float))

    use apex_x <- form.field("apex-x", form.parse_float)
    use apex_y <- form.field("apex-y", form.parse_float)
    use apex_h <- form.field(
      "apex-h",
      form.parse_float |> form.check_float_more_than(0.0),
    )

    form.success(Pyramid(
      base: list.map2(xs, ys, Point),
      apex: Apex(apex_x, apex_y, apex_h),
    ))
  })
}

pub type Message {
  UserClickedReset
  UserClickedAddPoint
  UserClickedRemovePoint
  UserClickedCalculate(List(#(String, String)))
}

pub fn update(model: Model, message: Message) -> Model {
  case message {
    UserClickedReset -> new_model(model.count)
    UserClickedAddPoint -> {
      new_model(model.count + 1)
    }
    UserClickedRemovePoint -> {
      new_model(model.count - 1)
    }
    UserClickedCalculate(values) -> {
      let filled = model.state |> form.set_values(values)
      case filled |> form.run {
        Ok(pyramid) -> Model(..model, state: filled, output: Some(pyramid))
        Error(_) -> Model(..model, state: filled, output: None)
      }
    }
  }
}
